defmodule Day10P1 do
  def solve(filename) do
    File.read!(filename)
    |> String.trim()
    |> String.split("\n")
    |> grid_to_map()
    |> traverse()
  end

  defp traverse(grid, positions \\ nil, distance \\ 0, explored \\ MapSet.new()) do
    positions =
      if positions == nil do
        [Enum.find(grid, fn {_, v} -> v == "S" end) |> elem(0)]
      else
        positions
      end

    new_positions =
      positions
      |> Enum.flat_map(fn {px, py} ->
        [
          {{-1, 0}, ["L", "F", "-"]},
          {{1, 0}, ["7", "J", "-"]},
          {{0, -1}, ["7", "F", "|"]},
          {{0, 1}, ["L", "J", "|"]}
        ]
        |> Enum.reduce([], fn {{dx, dy}, valid}, acc ->
          new_pos = {px + dx, py + dy}
          tile = Map.get(grid, new_pos)

          if Enum.member?(valid, tile) && !MapSet.member?(explored, new_pos) do
            acc ++ [new_pos]
          else
            acc
          end
        end)
      end)

    explored = MapSet.union(explored, MapSet.new(positions))

    if Enum.count(new_positions) != 0 do
      traverse(grid, new_positions, distance + 1, explored)
    else
      distance
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
end
