defmodule Day03P2 do
  def solve(filename) do
    grid =
      File.read!(filename)
      |> String.trim()
      |> String.split("\n")
      |> grid_to_map()

    {numbers, _} = map_line(grid)

    symbol_grid = Map.filter(grid, fn {_, n} -> Integer.parse(n) == :error end)

    symbol_grid
    |> Map.filter(fn {_, s} -> s == "*" end)
    |> Enum.map(&gear_ratio(numbers, &1))
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

  defp gear_ratio(numbers, {{x, y}, _}) do
    list = [
      Map.get(numbers, {x - 1, y - 1}),
      Map.get(numbers, {x - 1, y}),
      Map.get(numbers, {x - 1, y + 1}),
      Map.get(numbers, {x, y + 1}),
      Map.get(numbers, {x, y - 1}),
      Map.get(numbers, {x + 1, y - 1}),
      Map.get(numbers, {x + 1, y}),
      Map.get(numbers, {x + 1, y + 1}),
      get_if_big(numbers, {x - 2, y - 1}, 2),
      get_if_big(numbers, {x - 2, y}, 2),
      get_if_big(numbers, {x - 2, y + 1}, 2),
      get_if_big(numbers, {x - 2, y - 1}, 3),
      get_if_big(numbers, {x - 2, y + 1}, 3),
      get_if_big(numbers, {x - 3, y - 1}, 3),
      get_if_big(numbers, {x - 3, y}, 3),
      get_if_big(numbers, {x - 3, y + 1}, 3)
    ]

    list = Enum.filter(list, fn n -> n != nil end)

    if Enum.count(list) == 2 do
      [left, right] = list
      String.to_integer(left) * String.to_integer(right)
    else
      0
    end
  end

  defp get_if_big(numbers, {x, y}, length) do
    v = Map.get(numbers, {x, y})

    if v != nil && String.length(v) == length do
      v
    else
      nil
    end
  end
end
