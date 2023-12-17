defmodule Day17P1A do
  def solve(filename) do
    {width, height, grid} =
      File.read!(filename)
      |> String.trim()
      |> String.split("\n")
      |> grid_to_map()
      |> grid_info()

    a_star(grid, {width, height}, MapSet.new([{0, 0}]), %{
      {0, 0} => %{g: 0, h: 0, f: 0, parent: nil}
    })
  end

  defp a_star(grid, {ex, ey} = end_pos, open_set, costs) do
    {_, current_node} =
      for n <- open_set, reduce: {10_000_000, nil} do
        {f_cost, current_node} ->
          f = Map.get(costs, n).f

          if f < f_cost do
            {f, n}
          else
            {f_cost, current_node}
          end
      end

    open_set = MapSet.delete(open_set, current_node)
    {cx, cy} = current_node

    if current_node == end_pos do
      find_path(grid, costs, current_node, Map.get(grid, current_node))
    else
      new_positions =
        for {dx, dy} <- [{1, 0}, {-1, 0}, {0, 1}, {0, -1}], reduce: [] do
          next_list ->
            new_pos = {cx + dx, cy + dy}

            back_4 = find_long_parent(costs, {cx, cy})

            if !Map.has_key?(costs, {cx + dx, cy + dy}) do
              [new_pos] ++ next_list
            else
              next_list
            end

            if back_4 do
              {px, py} = back_4

              if abs(cx + dx - px) > 4 || abs(cy + dy - py) > 4 do
                next_list
              else
                if !Map.has_key?(costs, {cx + dx, cy + dy}) do
                  [new_pos] ++ next_list
                else
                  next_list
                end

                #                [new_pos] ++ next_list
              end
            else
              if !Map.has_key?(costs, {cx + dx, cy + dy}) do
                [new_pos] ++ next_list
              else
                next_list
              end
            end
        end

      {open_set, costs} =
        for {x, y} = pos <- new_positions, reduce: {open_set, costs} do
          {open_set, costs} ->
            #            g = abs(cx - x) + abs(cy - y)
            g = Map.get(grid, {x, y})

            if g < Map.get(costs, pos, %{g: 1_000_000_000_000_000}).g do
              h = (abs(cx - ex) + abs(cy - ey)) * 9
              c = %{g: g, f: g + h, h: h, parent: current_node}

              {MapSet.put(open_set, pos), Map.put(costs, pos, c)}
            else
              {open_set, costs}
            end
        end

      a_star(grid, end_pos, open_set, costs)
    end
  end

  defp find_long_parent(costs, node) do
    back = Map.get(costs, node)

    if back && back.parent do
      back_2 = Map.get(costs, back.parent)

      if back_2 && back_2.parent do
        back_3 = Map.get(costs, back_2.parent)

        if back_3 && back_3.parent do
          back_3.parent
        end
      end
    end
  end

  defp find_path(grid, costs, node, heat) do
    #    IO.inspect(node)
    n = Map.get(costs, node)
    parent = Map.get(costs, node).parent

    if n.parent == nil do
      heat + n.g
    else
      find_path(grid, costs, parent, heat + n.g)
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
end
