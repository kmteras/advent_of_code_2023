defmodule Day17P1 do
  def solve(filename) do
    {width, height, grid} = File.read!(filename)
                            |> String.trim()
                            |> String.split("\n")
                            |> grid_to_map()
                            |> grid_info()

    {nodes, cur_dis} = dijkstra(grid, {0, 0}, Map.new(), {width, height})

    {Enum.filter(nodes, fn {{{x, y}, dir, s}, v} -> x == width && y == height end), cur_dis}
  end

  defp get_path_set(prev, node, set \\ MapSet.new(), {width, height}) do
    set = MapSet.put(set, node)
    prev_node = Map.get(prev, node)

    if prev_node != nil do
      get_path_set(prev, prev_node, set)
    else
      set
    end
  end

  defp get_path(prev, node) do
    prev_node = Map.get(prev, node)

    IO.inspect(node)

    if prev_node != nil do
      get_path(prev, prev_node)
    end
  end

  defp get_distance(dist, prev, node, total \\ 0) do
    Map.get(dist, node)
  end

  defp dijkstra(grid, source, dist, {width, height}) do
    nodes =
      Map.keys(grid)
      |> MapSet.new()

    dist =
      Map.keys(grid)
      |> Enum.map(fn k -> {k, 10000000000} end)
      |> Map.new()

    dist = Map.put(dist, source, 0)
    prev = Map.new()

    nodes = HeapQueue.new()

    nodes = HeapQueue.push(nodes, 0, {{0,0}, {1, 0}, 0})
    nodes = HeapQueue.push(nodes, 0, {{0,0}, {0, 1}, 0})

#    nodes = HeapQueue.new([
#      0, {0,0}, {1, 0}, 0,
#      0, {0,0}, {0, 1}, 0
#    ])

    dijkstra_cont(grid, nodes, dist, prev, Map.new(), {width, height})
  end

  defp dijkstra_cont(grid, nodes, dist, prev, matched_nodes, {width, height}) do
#    IO.inspect(HeapQueue.size(nodes))

    {{:value, cur_dis, {{x, y}, {dx, dy} = dir, s}}, nodes} = HeapQueue.pop(nodes)

    IO.inspect(cur_dis)
    #    IO.inspect(HeapQueue.pop(nodes))

#    {{x, y}, {dx, dy} = dir, s, cur_dis} = node = nodes
#       |> Enum.min_by(fn {k, dir, s, cur_dis} -> cur_dis end)
#    nodes = MapSet.delete(nodes, node)
#    matched_nodes = Map.put_new(matched_nodes, {{x, y}, dir, s}, cur_dis)
#    matched_nodes = Map.update(matched_nodes, {{x, y}, dir}, cur_dis, fn existing ->
#      min(existing, cur_dis)
#    end)

#    if x == width && y == height do
    cond do
      x == width && y == height ->
        {matched_nodes, cur_dis}

      Map.has_key?(matched_nodes, {{x, y}, dir, s}) ->
        dijkstra_cont(grid, nodes, dist, prev, matched_nodes, {width, height})

      true ->

        matched_nodes = Map.put_new(matched_nodes, {{x, y}, dir, s}, cur_dis)
      all_directions = [{1, 0}, {-1, 0}, {0, 1}, {0, -1}]

#      directions = Enum.reject(all_directions, fn v -> v == reverse(dir) end)

      straight = {x + dx, y + dy}
#      existing_straight = Map.get(matched_nodes, {straight, dir})

      nodes = if s < 3 && Map.has_key?(grid, straight) do
        distance = cur_dis + Map.get(grid, straight)

#        MapSet.put(nodes, {straight, dir, s + 1, distance})
        HeapQueue.push(nodes, distance, {straight, dir, s + 1})
      else
        nodes
      end

      {ldx, ldy} = left_dir = left(dir)
      left_pos = {x + ldx, y + ldy}

      nodes = if Map.has_key?(grid, left_pos) do
        distance = cur_dis + Map.get(grid, left_pos)
#        MapSet.put(nodes, {left_pos, left_dir, 1, distance})
        HeapQueue.push(nodes, distance, {left_pos, left_dir, 1})
      else
        nodes
      end

      {rdx, rdy} = right_dir = right(dir)
      right_pos = {x + rdx, y + rdy}

      nodes = if Map.has_key?(grid, right_pos) do
        distance = cur_dis + Map.get(grid, right_pos)
#        MapSet.put(nodes, {right_pos, right_dir, 1, distance})
        HeapQueue.push(nodes, distance, {right_pos, right_dir, 1})
      else
        nodes
      end

#      {nodes, dist, prev} = Enum.reduce(directions, {nodes, dist, prev}, fn {dx, dy}, {nodes, dist, prev} ->
#        nn = {x + dx, y + dy}
#
#        s = if dir == {dx, dy} do
#          s + 1
#        else
#          1
#        end
#
#        if Map.has_key?(grid, nn) do
##          current = Map.get(dist, {x, y})
#          distance = cur_dis + Map.get(grid, nn)
#
#          nodes = if !Map.has_key?(matched_nodes, {nn, {dx, dy}}) && (s < 4 || s < 3 && dir == {dx, dy}) do
#            MapSet.put(nodes, {nn, {dx, dy}, s, distance})
#          else
#            nodes
#          end
#
#          {nodes, dist, prev}
#        else
#          {nodes, dist, prev}
#        end
#      end)

      dijkstra_cont(grid, nodes, dist, prev, matched_nodes, {width, height})
    end
  end

  defp left(direction) do
    case direction do
      {1, 0} -> {0, -1}
      {-1, 0} -> {0, 1}
      {0, 1} -> {-1, 0}
      {0, -1} -> {1, 0}
    end
  end

  defp right(direction) do
    reverse(left(direction))
  end

  defp reverse(direction) do
    case direction do
      {1, 0} -> {-1, 0}
      {-1, 0} -> {1, 0}
      {0, 1} -> {0, -1}
      {0, -1} -> {0, 1}
    end
  end

  defp grid_info(grid) do
    {{width, _}, _} = Enum.max_by(grid, fn {{x, _}, _} -> x end)
    {{_, height}, _} = Enum.max_by(grid, fn {{_, y}, _} -> y end)

    {width, height, grid}
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
                  Map.put(map, {x, y}, String.to_integer(risk))
                end
              )
           |> Map.merge(map)
         end
       )
  end

  defp pretty_grid(width, height, map \\ MapSet.new()) do
    0..height
    |> Enum.map(fn y ->
      ""
      0..width
      |> Enum.map(fn x ->
        if MapSet.member?(map, {x, y}) do
          "#"
        else
          "."
        end
      end)
      |> Enum.join("")
      |> IO.inspect(pretty: true)
    end)
    #    |> Enum.join("\n")
    #    |> IO.inspect(pretty: true)
  end
end
