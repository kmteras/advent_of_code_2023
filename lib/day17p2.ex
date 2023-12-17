defmodule Day17P2 do
  def solve(filename) do
    {width, height, grid} =
      File.read!(filename)
      |> String.trim()
      |> String.split("\n")
      |> grid_to_map()
      |> grid_info()

    {nodes, cur_dis} = dijkstra(grid, {0, 0}, {width, height})

    {Enum.filter(nodes, fn {{{x, y}, _, _}, _} -> x == width && y == height end), cur_dis}
  end

  defp dijkstra(grid, source, {width, height}) do
    dist =
      Map.keys(grid)
      |> Enum.map(fn k -> {k, 10_000_000_000} end)
      |> Map.new()

    dist = Map.put(dist, source, 0)
    prev = Map.new()

    nodes = HeapQueue.new()

    nodes = HeapQueue.push(nodes, 0, {{0, 0}, {1, 0}, 0})
    nodes = HeapQueue.push(nodes, 0, {{0, 0}, {0, 1}, 0})

    dijkstra_cont(grid, nodes, dist, prev, Map.new(), {width, height})
  end

  defp dijkstra_cont(grid, nodes, dist, prev, matched_nodes, {width, height}) do
    {{:value, cur_dis, {{x, y}, {dx, dy} = dir, s}}, nodes} = HeapQueue.pop(nodes)

    cond do
      x == width && y == height ->
        {matched_nodes, cur_dis}

      Map.has_key?(matched_nodes, {{x, y}, dir, s}) ->
        dijkstra_cont(grid, nodes, dist, prev, matched_nodes, {width, height})

      true ->
        matched_nodes = Map.put_new(matched_nodes, {{x, y}, dir, s}, cur_dis)

        straight = {x + dx, y + dy}

        nodes =
          if s < 10 && Map.has_key?(grid, straight) do
            distance = cur_dis + Map.get(grid, straight)

            HeapQueue.push(nodes, distance, {straight, dir, s + 1})
          else
            nodes
          end

        {ldx, ldy} = left_dir = left(dir)
        left_pos = {x + ldx, y + ldy}

        nodes =
          if Map.has_key?(grid, left_pos) && s >= 4 do
            distance = cur_dis + Map.get(grid, left_pos)
            HeapQueue.push(nodes, distance, {left_pos, left_dir, 1})
          else
            nodes
          end

        {rdx, rdy} = right_dir = right(dir)
        right_pos = {x + rdx, y + rdy}

        nodes =
          if Map.has_key?(grid, right_pos) && s >= 4 do
            distance = cur_dis + Map.get(grid, right_pos)
            HeapQueue.push(nodes, distance, {right_pos, right_dir, 1})
          else
            nodes
          end

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

  #  defp pretty_grid(width, height, map \\ MapSet.new()) do
  #    0..height
  #    |> Enum.map(fn y ->
  #      ""
  #
  #      0..width
  #      |> Enum.map(fn x ->
  #        if MapSet.member?(map, {x, y}) do
  #          "#"
  #        else
  #          "."
  #        end
  #      end)
  #      |> Enum.join("")
  #      |> IO.inspect(pretty: true)
  #    end)
  #  end
end
