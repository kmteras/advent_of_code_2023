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
      if MapSet.member?(checked, {ox, oy}) || Integer.parse(n) == :error do
        {acc, checked}
      else
        right =
          case Map.get(grid, {ox + 1, oy}) do
            nil ->
              {{ox, oy}, n, checked}

            res ->
              case Integer.parse(res) do
                :error ->
                  {{ox, oy}, n, checked}

                {_, _} ->
                  n = n <> res
                  checked = MapSet.put(checked, {ox + 1, oy})

                  case Map.get(grid, {ox + 2, oy}) do
                    nil ->
                      {{ox, oy}, n, checked}

                    res ->
                      case Integer.parse(res) do
                        :error ->
                          {{ox, oy}, n, checked}

                        {_, _} ->
                          {{ox, oy}, n <> res, MapSet.put(checked, {ox + 2, oy})}
                      end
                  end
              end
          end

        case right do
          nil ->
            {acc, checked}

          {{x, y}, n, checked} ->
            left =
              case Map.get(grid, {ox - 1, oy}) do
                nil ->
                  nil

                res ->
                  case Integer.parse(res) do
                    :error ->
                      {{ox, oy}, n, checked}

                    {_, _} ->
                      n = res <> n
                      checked = MapSet.put(checked, {ox - 1, oy})

                      case Map.get(grid, {ox - 2, oy}) do
                        nil ->
                          {{ox - 1, oy}, n, checked}

                        res ->
                          case Integer.parse(res) do
                            :error ->
                              {{ox - 1, oy}, n, checked}

                            {_, _} ->
                              {{ox - 2, oy}, res <> n, MapSet.put(checked, {ox - 2, oy})}
                          end
                      end
                  end
              end

            case left do
              {{x, y}, n, checked} ->
                {Map.put(acc, {x, y}, n), checked}

              nil ->
                {Map.put(acc, {x, y}, n), checked}
            end
        end
      end
    end)
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
