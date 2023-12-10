defmodule Day10P2 do
  def solve(filename) do
    File.read!(filename)
    |> String.trim()
    |> String.split("\n")
    |> grid_to_map()
    |> traverse()
    |> count_inside()
  end

  defp traverse(
         grid,
         positions \\ nil,
         distance \\ 0,
         explored \\ MapSet.new(),
         search_area_l \\ MapSet.new(),
         search_area_r \\ MapSet.new()
       ) do
    positions =
      if positions == nil do
        [Enum.find(grid, fn {_, v} -> v == "S" end) |> elem(0)]
      else
        positions
      end

    new_positions =
      positions
      |> Enum.flat_map(fn {px, py} ->
        cond do
          Enum.member?(["7", "J", "-", "S"], Map.get(grid, {px, py})) &&
            Enum.member?(["L", "F", "-"], Map.get(grid, {px - 1, py})) &&
              !MapSet.member?(explored, {px - 1, py}) ->
            {search_l, search_r} =
              case Map.get(grid, {px - 1, py}) do
                "L" -> {[{px, py - 1}], [{px, py + 1}, {px - 1, py + 1}, {px - 2, py}]}
                "F" -> {[{px, py - 1}, {px - 1, py - 1}, {px - 2, py}], [{px, py + 1}]}
                "-" -> {[{px, py - 1}], [{px, py + 1}]}
              end

            [{px - 1, py}, search_l, search_r]

          Enum.member?(["L", "F", "-", "S"], Map.get(grid, {px, py})) &&
            Enum.member?(["7", "J", "-"], Map.get(grid, {px + 1, py})) &&
              !MapSet.member?(explored, {px + 1, py}) ->
            {search_l, search_r} =
              case Map.get(grid, {px + 1, py}) do
                "J" -> {[{px, py + 1}, {px + 1, py + 1}, {px + 2, py}], [{px, py - 1}]}
                "7" -> {[{px, py + 1}], [{px, py - 1}, {px + 1, py - 1}, {px + 2, py}]}
                "-" -> {[{px, py + 1}], [{px, py - 1}]}
              end

            [{px + 1, py}, search_l, search_r]

          Enum.member?(["L", "J", "|", "S"], Map.get(grid, {px, py})) &&
            Enum.member?(["7", "F", "|"], Map.get(grid, {px, py - 1})) &&
              !MapSet.member?(explored, {px, py - 1}) ->
            {search_l, search_r} =
              case Map.get(grid, {px, py - 1}) do
                "7" -> {[{px + 1, py}, {px + 1, py - 1}, {px, py - 2}], [{px - 1, py}]}
                "F" -> {[{px + 1, py}], [{px - 1, py}, {px - 1, py - 1}, {px, py - 2}]}
                "|" -> {[{px + 1, py}], [{px - 1, py}]}
              end

            [{px, py - 1}, search_l, search_r]

          Enum.member?(["7", "F", "|", "S"], Map.get(grid, {px, py})) &&
            Enum.member?(["L", "J", "|"], Map.get(grid, {px, py + 1})) &&
              !MapSet.member?(explored, {px, py + 1}) ->
            {search_l, search_r} =
              case Map.get(grid, {px, py + 1}) do
                "|" -> {[{px - 1, py}], [{px + 1, py}]}
                "L" -> {[{px - 1, py}, {px - 1, py + 1}, {px, py + 2}], [{px + 1, py}]}
                "J" -> {[{px - 1, py}], [{px + 1, py}, {px - 1, py + 1}, {px, py + 2}]}
              end

            [{px, py + 1}, search_l, search_r]

          true ->
            []
        end
      end)

    explored = MapSet.union(explored, MapSet.new(positions))

    if Enum.count(new_positions) != 0 do
      [new_positions, new_search_area_l, new_search_area_r] = new_positions

      search_area_l = MapSet.union(search_area_l, MapSet.new(new_search_area_l))
      search_area_r = MapSet.union(search_area_r, MapSet.new(new_search_area_r))

      traverse(grid, [new_positions], distance + 1, explored, search_area_l, search_area_r)
    else
      {grid, explored, search_area_l, search_area_r}
    end
  end

  defp count_inside({grid, explored, search_area_l, search_area_r}) do
    search_area_l =
      search_area_l
      |> Enum.filter(fn v -> !MapSet.member?(explored, v) end)

    search_area_r =
      search_area_r
      |> Enum.filter(fn v -> !MapSet.member?(explored, v) end)

    search_area_l = look_for_neighbors(MapSet.new(Map.keys(grid)), explored, search_area_l)
    search_area_r = look_for_neighbors(MapSet.new(Map.keys(grid)), explored, search_area_r)

    max(Enum.count(search_area_l), Enum.count(search_area_r))
  end

  defp look_for_neighbors(valid, explored, search_area) do
    new_search_area =
      search_area
      |> Enum.flat_map(fn {x, y} ->
        Enum.reduce([{-1, 0}, {1, 0}, {0, -1}, {0, 1}, {0, 0}], [], fn {dx, dy}, list ->
          coord = {x + dx, y + dy}

          if !MapSet.member?(explored, coord) do
            if !MapSet.member?(valid, coord) do
              list ++ [:invalid]
            else
              list ++ [coord]
            end
          else
            list
          end
        end)
      end)
      |> MapSet.new()

    if Enum.member?(new_search_area, :invalid) do
      []
    else
      if Enum.count(new_search_area) == Enum.count(search_area) do
        new_search_area
      else
        look_for_neighbors(valid, explored, new_search_area)
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
            Map.put(map, {x, y}, risk)
          end
        )
        |> Map.merge(map)
      end
    )
  end
end
