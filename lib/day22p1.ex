defmodule Day22P1 do
  def solve(filename) do
    File.read!(filename)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&parse_line/1)
    |> MapSet.new()
    |> fall()
    |> IO.inspect()
    |> try_fall()
    |> Enum.map(fn {:ok, v} -> v end)
    |> Enum.sum()
  end

  defp try_fall(bricks) do
    Task.async_stream(bricks, fn brick ->
      IO.inspect(brick)

      bricks = MapSet.delete(bricks, brick)

      if can_fall?(bricks) do
        0
      else
        1
      end
    end)
  end

  defp can_fall?(bricks) do
    new_bricks =
      for brick <- bricks, reduce: MapSet.new() do
        new_bricks ->
          if settled?(brick, bricks) do
            MapSet.put(new_bricks, brick)
          else
            {{x1, y1, z1}, {x2, y2, z2}} = brick

            MapSet.put(new_bricks, {{x1, y1, z1 - 1}, {x2, y2, z2 - 1}})
          end
      end

    if MapSet.equal?(new_bricks, bricks) do
      false
    else
      true
    end
  end

  defp fall(bricks) do
    new_bricks =
      for brick <- bricks, reduce: MapSet.new() do
        new_bricks ->
          if settled?(brick, bricks) do
            MapSet.put(new_bricks, brick)
          else
            {{x1, y1, z1}, {x2, y2, z2}} = brick

            MapSet.put(new_bricks, {{x1, y1, z1 - 1}, {x2, y2, z2 - 1}})
          end
      end

    if MapSet.equal?(new_bricks, bricks) do
      new_bricks
    else
      fall(new_bricks)
    end
  end

  defp settled?({{_, _, 1}, _}, _), do: true

  defp settled?({{x1, y1, z1}, {x2, y2, _}} = brick, bricks) do
    Enum.reduce_while(x1..x2, false, fn x, _ ->
      stable =
        Enum.reduce_while(y1..y2, false, fn y, _ ->
          stable =
            Enum.any?(bricks, fn {{bx1, by1, _}, {bx2, by2, bz2}} = b ->
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
