defmodule Day21P1 do
  def solve(filename) do
    File.read!(filename)
    |> String.trim()
    |> String.split("\n")
    |> grid_to_map()
    |> look_for_neighbors()
  end

  defp look_for_neighbors(_, current_positions, _, 64) do
    #    IO.inspect(current_positions)
    Enum.count(current_positions)
  end

  defp look_for_neighbors(grid, current_positions \\ nil, explored \\ MapSet.new(), steps \\ 0) do
    current_positions =
      if current_positions == nil do
        {p, _} = Enum.find(grid, fn {p, v} -> v == "S" end)
        MapSet.new([p])
      else
        current_positions
      end

    {current_positions, explored} =
      for {x, y} <- current_positions, reduce: {current_positions, explored} do
        {current_positions, explored} ->
          for {dx, dy} <- [{-1, 0}, {1, 0}, {0, -1}, {0, 1}],
              reduce: {current_positions, explored} do
            {current_positions, explored} ->
              p = {x + dx, y + dy}

              current_positions = MapSet.delete(current_positions, {x, y})

              if Map.get(grid, p) != nil do
                {MapSet.put(current_positions, p), MapSet.put(explored, p)}
              else
                {current_positions, explored}
              end
          end
      end

    look_for_neighbors(grid, current_positions, explored, steps + 1)
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
            if risk != "#" do
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
