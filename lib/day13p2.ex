defmodule Day13P2 do
  def solve(filename) do
    File.read!(filename)
    |> String.trim()
    |> String.split("\n\n")
    |> Enum.map(&map_input/1)
    |> Enum.map(&reflections/1)
    |> Enum.sum()
  end

  defp reflections(grid) do
    grid = MapSet.new(Map.keys(grid))
    {width, _} = Enum.max_by(grid, fn {x, _} -> x end)
    {_, height} = Enum.max_by(grid, fn {_, y} -> y end)

    l_r =
      1..width
      |> Enum.find(fn cutoff ->
        left =
          grid
          |> Enum.filter(fn {x, _y} -> x < cutoff end)
          |> MapSet.new()

        right =
          grid
          |> Enum.filter(fn {x, _y} -> x >= cutoff end)
          |> Enum.map(fn {x, y} -> {2 * cutoff - x - 1, y} end)
          |> Enum.filter(fn {x, _y} -> x >= 0 end)
          |> MapSet.new()

        left_diff = MapSet.difference(left, right)
        right_diff = MapSet.difference(right, left)

        not_valid = MapSet.reject(left_diff, fn {x, _} -> x < 2 * cutoff - 1 - width end)

        (Enum.count(not_valid) == 1 && Enum.count(right_diff) == 0) ||
          (Enum.count(not_valid) == 0 && Enum.count(right_diff) == 1)
      end)

    u_d =
      1..height
      |> Enum.find(fn cutoff ->
        up =
          grid
          |> Enum.filter(fn {_x, y} -> y < cutoff end)
          |> MapSet.new()

        down =
          grid
          |> Enum.filter(fn {_x, y} -> y >= cutoff end)
          |> Enum.map(fn {x, y} -> {x, 2 * cutoff - y - 1} end)
          |> Enum.filter(fn {_x, y} -> y >= 0 end)
          |> MapSet.new()

        up_diff = MapSet.difference(up, down)
        down_diff = MapSet.difference(down, up)

        not_valid = MapSet.reject(up_diff, fn {_, y} -> y < 2 * cutoff - 1 - height end)

        (Enum.count(not_valid) == 1 && Enum.count(down_diff) == 0) ||
          (Enum.count(not_valid) == 0 && Enum.count(down_diff) == 1)
      end)

    if l_r do
      l_r
    else
      u_d * 100
    end
  end

  defp map_input(list) do
    grid_to_map(String.split(list, "\n"))
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
            if risk == "#" do
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
