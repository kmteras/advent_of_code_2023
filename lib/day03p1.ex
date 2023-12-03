defmodule Day03P1 do
  def solve(filename) do
    grid =
      File.read!(filename)
      |> String.trim()
      |> String.split("\n")
      |> grid_to_map()

    {numbers, _} = map_line(grid)

    symbol_grid = Map.filter(grid, fn {_, n} -> Integer.parse(n) == :error end)

    numbers
    |> Enum.filter(&has_adjacent_symbol?(symbol_grid, &1))
    |> Enum.map(fn {_, num} -> String.to_integer(num) end)
    |> Enum.sum()
  end

  defp map_line(grid) do
    Enum.reduce(grid, {%{}, MapSet.new([])}, fn {{ox, oy}, n}, {acc, checked} ->
      # Check if number was already used by building something else or current value is symbol
      if MapSet.member?(checked, {ox, oy}) || Integer.parse(n) == :error do
        {acc, checked}
      else
        {{x, y}, n, checked, _} =
          case look_for_value(grid, checked, n, {ox, oy}, 1) do
            {{x, y}, n, checked, true} ->
              look_for_value(grid, checked, n, {ox, oy}, 2)

            res ->
              res
          end

        {{x, y}, n, checked, _} =
          case look_for_value(grid, checked, n, {ox, oy}, -1) do
            {{x, y}, n, checked, true} ->
              case look_for_value(grid, checked, n, {ox, oy}, -2) do
                {{x, y}, n, checked, true} = res -> res
                # Return x and y from previous find
                res -> {{x, y}, n, checked, false}
              end

            res ->
              res
          end

        {Map.put(acc, {x, y}, n), checked}
      end
    end)
  end

  defp look_for_value(grid, checked, n, {ox, oy}, dx) do
    case Map.get(grid, {ox + dx, oy}) do
      nil ->
        {{ox, oy}, n, checked, false}

      res ->
        case Integer.parse(res) do
          :error ->
            {{ox, oy}, n, checked, false}

          {_, _} ->
            word =
              if dx > 0 do
                n <> res
              else
                res <> n
              end

            # Adjust origin if looking back
            x =
              if dx < 0 do
                ox + dx
              else
                ox
              end

            {{x, oy}, word, MapSet.put(checked, {ox + dx, oy}), true}
        end
    end
  end

  defp grid_to_map(grid) do
    grid
    |> Enum.map(&String.graphemes/1)
    |> Enum.with_index()
    |> Enum.reduce(
      %{},
      fn {line, y}, map ->
        line
        |> Enum.with_index()
        |> Enum.reduce(
          %{},
          fn {risk, x}, map ->
            if risk != "." do
              Map.put(map, {x, y}, risk)
            else
              map
            end
          end
        )
        |> Map.merge(map)
      end
    )
  end

  defp has_adjacent_symbol?(grid, {{x, y}, num}) do
    case String.length(num) do
      1 ->
        Map.has_key?(grid, {x, y + 1}) ||
          Map.has_key?(grid, {x + 1, y + 1}) ||
          Map.has_key?(grid, {x - 1, y + 1}) ||
          Map.has_key?(grid, {x, y - 1}) ||
          Map.has_key?(grid, {x + 1, y - 1}) ||
          Map.has_key?(grid, {x - 1, y - 1}) ||
          Map.has_key?(grid, {x - 1, y}) ||
          Map.has_key?(grid, {x + 1, y})

      2 ->
        Map.has_key?(grid, {x, y + 1}) ||
          Map.has_key?(grid, {x + 1, y + 1}) ||
          Map.has_key?(grid, {x + 2, y + 1}) ||
          Map.has_key?(grid, {x - 1, y + 1}) ||
          Map.has_key?(grid, {x, y - 1}) ||
          Map.has_key?(grid, {x + 1, y - 1}) ||
          Map.has_key?(grid, {x + 2, y - 1}) ||
          Map.has_key?(grid, {x - 1, y - 1}) ||
          Map.has_key?(grid, {x - 1, y}) ||
          Map.has_key?(grid, {x + 2, y})

      3 ->
        Map.has_key?(grid, {x, y + 1}) ||
          Map.has_key?(grid, {x + 1, y + 1}) ||
          Map.has_key?(grid, {x + 2, y + 1}) ||
          Map.has_key?(grid, {x + 3, y + 1}) ||
          Map.has_key?(grid, {x - 1, y + 1}) ||
          Map.has_key?(grid, {x, y - 1}) ||
          Map.has_key?(grid, {x + 1, y - 1}) ||
          Map.has_key?(grid, {x + 2, y - 1}) ||
          Map.has_key?(grid, {x + 3, y - 1}) ||
          Map.has_key?(grid, {x - 1, y - 1}) ||
          Map.has_key?(grid, {x - 1, y}) ||
          Map.has_key?(grid, {x + 3, y})
    end
  end
end
