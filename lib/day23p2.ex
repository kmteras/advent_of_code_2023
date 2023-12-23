defmodule Day23P2 do
  def solve(filename) do
    :ets.new(:path_memory, [:set, :public, :named_table])

    File.read!(filename)
    |> String.trim()
    |> String.split("\n")
    |> grid_to_map()
    |> grid_info()
    |> traverse_maze([{{1, 0}, MapSet.new(), 0}], 0)
  end

  defp traverse_maze(_, [], max_dist) do
    max_dist
  end

  defp traverse_maze({{ex, ey}, grid}, [{{x, y}, matched_nodes, cur_dis} | nodes], max_dist) do
      cond do
        x == ex && y == ey ->
          if max(max_dist, cur_dis) != max_dist do
            IO.puts("New max: #{cur_dis}, keep waiting though!")
          end

          traverse_maze({{ex, ey}, grid}, nodes, max(max_dist, cur_dis))

        true ->
          matched_nodes = MapSet.put(matched_nodes, {x, y})

          nodes =
            for {dx, dy} <- [{1, 0}, {-1, 0}, {0, 1}, {0, -1}], reduce: nodes do
              nodes ->
                {pos, d} = case :ets.lookup(:path_memory, {{x, y}, {dx, dy}}) do
                  [{_params, {pos, d}}] ->
                    {pos, d}

                  [] ->
                    {pos, d} = move_out(grid, {x, y}, {dx, dy})

                    :ets.insert(:path_memory, {{{x, y}, {dx, dy}}, {pos, d}})

                    {pos, d}
                end

                if d > 0 && !MapSet.member?(matched_nodes, pos) do
                  distance = cur_dis + d

                  [{pos, matched_nodes, distance}] ++ nodes
                else
                  nodes
                end
            end

          traverse_maze({{ex, ey}, grid}, nodes, max_dist)
    end
  end

  defp move_out(grid, {x, y}, {dx, dy}, d \\ 0) do
    {px, py} = pos = {x + dx * (d + 1), y + dy * (d + 1)}
    if Map.has_key?(grid, pos) do
      no_other_path = case {dx, dy} do
        {1, 0} -> !Map.has_key?(grid, {px, py + 1}) && !Map.has_key?(grid, {px, py - 1})
        {-1, 0} -> !Map.has_key?(grid, {px, py + 1}) && !Map.has_key?(grid, {px, py - 1})
        {0, 1} -> !Map.has_key?(grid, {px + 1, py}) && !Map.has_key?(grid, {px - 1, py})
        {0, -1} -> !Map.has_key?(grid, {px + 1, py}) && !Map.has_key?(grid, {px - 1, py})
      end

      if no_other_path do
        move_out(grid, {x, y}, {dx, dy}, d + 1)
      else
        {pos, d + 1}
      end
    else
      {{x + dx * d, y + dy * d}, d}
    end
  end

  defp grid_info(grid) do
    {{width, _}, _} = Enum.max_by(grid, fn {{x, _}, _} -> x end)
    {{_, height}, _} = Enum.max_by(grid, fn {{_, y}, _} -> y end)

    {{width, height}, grid}
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
