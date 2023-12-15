defmodule Day14P2 do
  def solve(filename) do
    :ets.new(:memory, [:set, :public, :named_table])

    File.read!(filename)
    |> String.trim()
    |> String.split("\n")
    |> grid_to_map()
    |> grid_info()
    |> tilt_alot()
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
    {{width, _}, _} = Enum.max_by(grid, fn {{x, _}, _} -> x end)
    {{_, height}, _} = Enum.max_by(grid, fn {{_, y}, _} -> y end)

    {width, height, grid}
  end

  defp tilt_alot({width, height, grid}) do
    {from_memory, cycle, grid} =
      1..1_000_000_000
      |> Enum.reduce_while(grid, fn i, grid ->
        {new_grid, j, is_memory} =
          case :ets.lookup(:memory, grid) do
            [{_params, {ans, j}}] ->
              {ans, j, true}

            [] ->
              new_grid = tilt({width, height, grid})
              :ets.insert(:memory, {grid, {new_grid, i}})

              {new_grid, 0, false}
          end

        if is_memory do
          {:halt, {i, i - j, new_grid}}
        else
          {:cont, new_grid}
        end
      end)

    grid =
      0..(from_memory + cycle)
      |> Enum.reduce_while(grid, fn i, grid ->
        new_grid = tilt({width, height, grid})

        if rem(1_000_000_000 - from_memory - i, cycle) == 0 && i > from_memory do
          {:halt, grid}
        else
          {:cont, new_grid}
        end
      end)

    {height, grid}
  end

  defp tilt({width, height, grid}) do
    new_grid =
      Enum.reduce(grid, grid, fn {{x, y}, t}, grid ->
        if t == "#" do
          grid
        else
          new_place = move_rock_up(grid, width, height, {x, y})
          grid = Map.delete(grid, {x, y})
          Map.put(grid, {x, new_place}, "O")
        end
      end)

    new_grid =
      Enum.reduce(new_grid, new_grid, fn {{x, y}, t}, grid ->
        if t == "#" do
          grid
        else
          new_place = move_rock_left(grid, width, height, {x, y})
          grid = Map.delete(grid, {x, y})
          Map.put(grid, {new_place, y}, "O")
        end
      end)

    new_grid =
      Enum.reduce(new_grid, new_grid, fn {{x, y}, t}, grid ->
        if t == "#" do
          grid
        else
          new_place = move_rock_down(grid, width, height, {x, y})
          grid = Map.delete(grid, {x, y})
          Map.put(grid, {x, new_place}, "O")
        end
      end)

    Enum.reduce(new_grid, new_grid, fn {{x, y}, t}, grid ->
      if t == "#" do
        grid
      else
        new_place = move_rock_right(grid, width, height, {x, y})
        grid = Map.delete(grid, {x, y})
        Map.put(grid, {new_place, y}, "O")
      end
    end)
  end

  defp move_rock_up(grid, _, _, {x, y}) do
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
      if !Map.has_key?(grid, {x, current_height}) do
        min(current_height, acc)
      else
        acc
      end
    end)
  end

  defp move_rock_left(grid, _, _, {x, y}) do
    start_x =
      0..x
      |> Enum.reduce(0, fn current_width, acc ->
        if Map.get(grid, {current_width, y}) == "#" do
          max(current_width, acc)
        else
          acc
        end
      end)

    start_x..x
    |> Enum.reduce(x, fn current_width, acc ->
      if !Map.has_key?(grid, {current_width, y}) do
        min(current_width, acc)
      else
        acc
      end
    end)
  end

  defp move_rock_down(grid, _, height, {x, y}) do
    end_y =
      y..height
      |> Enum.reduce(height, fn current_height, acc ->
        if Map.get(grid, {x, current_height}) == "#" do
          min(current_height, acc)
        else
          acc
        end
      end)

    y..end_y
    |> Enum.reduce(y, fn current_height, acc ->
      if !Map.has_key?(grid, {x, current_height}) do
        max(current_height, acc)
      else
        acc
      end
    end)
  end

  defp move_rock_right(grid, width, _, {x, y}) do
    end_y =
      x..width
      |> Enum.reduce(width, fn current_width, acc ->
        if Map.get(grid, {current_width, y}) == "#" do
          min(current_width, acc)
        else
          acc
        end
      end)

    x..end_y
    |> Enum.reduce(x, fn current_width, acc ->
      if !Map.has_key?(grid, {current_width, y}) do
        max(current_width, acc)
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
