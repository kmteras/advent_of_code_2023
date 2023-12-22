defmodule Day22P2 do
  def solve(filename) do
    File.read!(filename)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&parse_line/1)
    |> to_map()
    |> fall()
    |> IO.inspect()
    |> try_fall()
    |> Enum.map(fn {:ok, v} -> v end)
    |> IO.inspect()
    |> Enum.sum()
  end

  defp to_map(bricks) do
    bricks
    |> Enum.with_index()
    |> Enum.reduce(Map.new(), fn {{{x1, y1, z1}, {x2, y2, z2}}, i}, new_map ->
      brick = {{x1, y1, z1}, {x2, y2, z2}, i}
      Map.update(new_map, z2, [brick], fn e -> [brick] ++ e end)
    end)
  end

  defp try_fall(bricks) do
    to_go_over =
      bricks
      |> Map.values()
      |> Enum.flat_map(fn v -> v end)

    Task.async_stream(
      to_go_over,
      fn brick ->
        {_, {_, _, z2}, _} = brick
        bricks_list = Map.get(bricks, z2)
        bricks_list = List.delete(bricks_list, brick)
        bricks = Map.put(bricks, z2, bricks_list)

        after_fall = fall(bricks)

        bef =
          bricks
          |> Map.values()
          |> Enum.flat_map(fn v -> v end)
          |> MapSet.new()

        aft =
          after_fall
          |> Map.values()
          |> Enum.flat_map(fn v -> v end)
          |> MapSet.new()

        c = Enum.count(MapSet.difference(bef, aft))
        IO.inspect({brick, c})
        c
      end,
      timeout: :infinity
    )
  end

  defp fall(bricks) do
    to_go_over =
      bricks
      |> Map.values()
      |> Enum.flat_map(fn v -> v end)

    new_bricks =
      for brick <- to_go_over, reduce: Map.new() do
        new_bricks ->
          {{_, _, _}, {_, _, z2}, _} =
            brick =
            if settled?(brick, bricks) do
              brick
            else
              {{x1, y1, z1}, {x2, y2, z2}, id} = brick

              {{x1, y1, z1 - 1}, {x2, y2, z2 - 1}, id}
            end

          Map.update(new_bricks, z2, [brick], fn e -> [brick] ++ e end)
      end

    new_v =
      new_bricks
      |> Map.values()
      |> Enum.flat_map(fn v -> v end)
      |> MapSet.new()

    if MapSet.equal?(new_v, MapSet.new(to_go_over)) do
      new_bricks
    else
      fall(new_bricks)
    end
  end

  defp settled?({{_, _, 1}, _, _}, _), do: true

  defp settled?({{x1, y1, z1}, {x2, y2, _}, _} = brick, bricks) do
    options = Map.get(bricks, z1 - 1, [])

    if Enum.count(options) == 0 do
      false
    else
      Enum.reduce_while(x1..x2, false, fn x, _ ->
        stable =
          Enum.reduce_while(y1..y2, false, fn y, _ ->
            stable =
              Enum.any?(options, fn {{bx1, by1, _}, {bx2, by2, bz2}, _} = b ->
                b != brick && bz2 == z1 - 1 && x >= bx1 && x <= bx2 && y >= by1 && y <= by2
              end)

            if stable do
              {:halt, true}
            else
              {:cont, false}
            end
          end)

        if stable do
          {:halt, true}
        else
          {:cont, false}
        end
      end)
    end
  end

  defp parse_line(line) do
    [c1, c2] = String.split(line, "~")

    [x1, y1, z1] =
      c1
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    [x2, y2, z2] =
      c2
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    {{x1, y1, z1}, {x2, y2, z2}}
  end
end
