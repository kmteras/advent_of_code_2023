defmodule Day18P1 do
  def solve(filename) do
    File.read!(filename)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&map_input/1)
    |> Enum.reduce({Map.new(), {0, 0}}, &dig/2)
    |> elem(0)
    |> fill()
    |> elem(0)
    |> Enum.count()
  end

  def fill(dug, {x, y} \\ {1, 1}, visited \\ MapSet.new()) do
    for {dx, dy} <- [{-1, 0}, {1, 0}, {0, -1}, {0, 1}], reduce: {dug, visited} do
      {dug, visited} ->
        pos = {x + dx, y + dy}

        if !MapSet.member?(visited, pos) && !Map.has_key?(dug, pos) do
          dug = Map.put(dug, pos, "#ffffff")
          visited = MapSet.put(visited, pos)

          fill(dug, pos, visited)
        else
          {dug, visited}
        end
    end
  end

  def dig({direction, amount, color}, {dug, {ox, oy}}) do
    for n <- 1..amount, reduce: {dug, {0, 0}} do
      {dug, _} ->
        new_coord =
          case direction do
            "U" -> {ox, oy - n}
            "D" -> {ox, oy + n}
            "R" -> {ox + n, oy}
            "L" -> {ox - n, oy}
          end

        dug = Map.put(dug, new_coord, color)

        {dug, new_coord}
    end
  end

  def map_input(input) do
    [direction, amount, color] = String.split(input, " ")
    amount = String.to_integer(amount)
    {direction, amount, color}
  end
end
