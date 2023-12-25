defmodule Day23P1 do
  @big_n 10_000_000

  def solve(filename) do
    :ets.new(:memory, [:set, :public, :named_table])

    initial_heap = HeapQueue.push(HeapQueue.new(), @big_n, {{1, 0}, MapSet.new()})

    File.read!(filename)
    |> String.trim()
    |> String.split("\n")
    |> grid_to_map()
    |> grid_info()
    |> traverse_maze(initial_heap, 0)
  end

  defp traverse_maze({{ex, ey}, grid}, nodes, max_dist) do
    {{:value, big_cur_dis, {{x, y}, matched_nodes}}, nodes} = HeapQueue.pop(nodes)

    cur_dis = @big_n - big_cur_dis

    cond do
      x == ex && y == ey ->
        if max(max_dist, cur_dis) != max_dist do
          IO.puts("New max: #{cur_dis}, keep waiting though!")
        end

        traverse_maze({{ex, ey}, grid}, nodes, max(max_dist, cur_dis))

      MapSet.member?(matched_nodes, {x, y}) ->
        traverse_maze({{ex, ey}, grid}, nodes, max_dist)

      true ->
        matched_nodes = MapSet.put(matched_nodes, {x, y})

        nodes =
          for {dx, dy} <- [{1, 0}, {-1, 0}, {0, 1}, {0, -1}], reduce: nodes do
            nodes ->
              pos = {x + dx, y + dy}

              if Map.has_key?(grid, pos) && !going_up_slope(Map.get(grid, pos), {dx, dy}) do
                distance = cur_dis + 1
                HeapQueue.push(nodes, @big_n - distance, {pos, matched_nodes})
              else
                nodes
              end
          end

        traverse_maze({{ex, ey}, grid}, nodes, max_dist)
    end
  end

  defp going_up_slope(tile, {dx, dy}) do
    case tile do
      "." -> false
      ">" -> dx == -1
      "<" -> dx == 1
      "^" -> dy == 1
      "v" -> dy == -1
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
