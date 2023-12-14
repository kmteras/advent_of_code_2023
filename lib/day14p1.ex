defmodule Day14P1 do
  def solve(filename) do
    File.read!(filename)
    |> String.trim()
    |> String.split("\n")
    |> grid_to_map()
    |> grid_info()
    |> tilt()
    |> weight()
    |> Enum.sum()
  end

  defp weight({height, grid}) do
    Enum.map(grid, fn {{_x, y}, t} ->
      if t == "O" do
        height + 1 - y
      else
        0
      end
    end)
  end

  defp grid_info(grid) do
    {{_, height}, _} = Enum.max_by(grid, fn {{_, y}, _} -> y end)

    {height, grid}
  end

  defp tilt({height, grid}) do
    new_grid =
      Enum.reduce(grid, grid, fn {{x, y}, t}, grid ->
        if t == "#" do
          grid
        else
          new_place = move_rock(grid, {x, y})
          grid = Map.delete(grid, {x, y})
          Map.put(grid, {x, new_place}, "O")
        end
      end)

    {height, new_grid}
  end

  defp move_rock(grid, {x, y}) do
    start_y =
      0..y
      |> Enum.reduce(0, fn current_height, acc ->
        if Map.get(grid, {x, current_height}) == "#" do
          max(current_height, acc)
        else
          acc
        end
      end)

    start_y..y
    |> Enum.reduce(y, fn current_height, acc ->
      !Map.has_key?(grid, {x, current_height})

      if !Map.has_key?(grid, {x, current_height}) do
        min(current_height, acc)
      else
        acc
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
end
