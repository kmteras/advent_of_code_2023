defmodule Day16P2 do
  def solve(filename) do
    File.read!(filename)
    |> String.trim()
    |> String.split("\n")
    |> grid_to_map()
    |> dimensions()
    |> directions()
  end

  defp dimensions(grid) do
    {{width, _}, _} = Enum.max_by(grid, fn {{x, _}, _v} -> x end)
    {{_, height}, _} = Enum.max_by(grid, fn {{_, y}, _v} -> y end)

    {grid, width, height}
  end

  defp directions({grid, width, height}) do
    top =
      0..width
      |> Enum.map(fn x ->
        :ets.new(:memory, [:set, :public, :named_table])
        visited = move_beam({grid, width, height}, {x, 0}, {0, 1})
        sum = Enum.count(visited)
        :ets.delete(:memory)
        sum
      end)
      |> Enum.max()

    bottom =
      0..width
      |> Enum.map(fn x ->
        :ets.new(:memory, [:set, :public, :named_table])
        visited = move_beam({grid, width, height}, {x, height}, {0, -1})
        sum = Enum.count(visited)
        :ets.delete(:memory)
        sum
      end)
      |> Enum.max()

    left =
      0..height
      |> Enum.map(fn y ->
        :ets.new(:memory, [:set, :public, :named_table])
        visited = move_beam({grid, width, height}, {0, y}, {1, 0})
        sum = Enum.count(visited)
        :ets.delete(:memory)
        sum
      end)
      |> Enum.max()

    right =
      0..height
      |> Enum.map(fn y ->
        :ets.new(:memory, [:set, :public, :named_table])
        visited = move_beam({grid, width, height}, {width, y}, {-1, 0})
        sum = Enum.count(visited)
        :ets.delete(:memory)
        sum
      end)
      |> Enum.max()

    Enum.max([top, bottom, left, right])
  end

  defp move_beam({grid, width, height}, {x, y}, {dx, dy}) do
    if :ets.lookup(:memory, {x, y, dx, dy}) != [] do
      MapSet.new()
    else
      visited = MapSet.new([{x, y}])
      :ets.insert(:memory, {{x, y, dx, dy}})

      case Map.get(grid, {x, y}) do
        nil ->
          if x < 0 || y < 0 || x > width || y > height do
            MapSet.new()
          else
            new_visited = move_beam({grid, width, height}, {x + dx, y + dy}, {dx, dy})
            MapSet.union(visited, new_visited)
          end

        "|" ->
          if dy == 0 do
            visited_up = move_beam({grid, width, height}, {x, y - 1}, {0, -1})
            visited_down = move_beam({grid, width, height}, {x, y + 1}, {0, 1})

            visited
            |> MapSet.union(visited_up)
            |> MapSet.union(visited_down)
          else
            new_visited = move_beam({grid, width, height}, {x + dx, y + dy}, {dx, dy})
            MapSet.union(visited, new_visited)
          end

        "-" ->
          if dx == 0 do
            visited_left = move_beam({grid, width, height}, {x - 1, y}, {-1, 0})
            visited_right = move_beam({grid, width, height}, {x + 1, y}, {1, 0})

            visited
            |> MapSet.union(visited_left)
            |> MapSet.union(visited_right)
          else
            new_visited = move_beam({grid, width, height}, {x + dx, y + dy}, {dx, dy})
            MapSet.union(visited, new_visited)
          end

        "/" ->
          {dx, dy} =
            case {dx, dy} do
              {1, 0} -> {0, -1}
              {-1, 0} -> {0, 1}
              {0, 1} -> {-1, 0}
              {0, -1} -> {1, 0}
            end

          new_visited = move_beam({grid, width, height}, {x + dx, y + dy}, {dx, dy})
          MapSet.union(visited, new_visited)

        "\\" ->
          {dx, dy} =
            case {dx, dy} do
              {1, 0} -> {0, 1}
              {-1, 0} -> {0, -1}
              {0, 1} -> {1, 0}
              {0, -1} -> {-1, 0}
            end

          new_visited = move_beam({grid, width, height}, {x + dx, y + dy}, {dx, dy})
          MapSet.union(visited, new_visited)
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
end
