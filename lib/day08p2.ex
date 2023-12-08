defmodule Day08P2 do
  def solve(filename) do
    File.read!(filename)
    |> String.trim()
    |> String.split("\n\n")
    |> map_input()
    |> move()
    |> elem(1)
  end

  defp map_input([instructions, map]) do
    map = String.split(map, "\n")

    map =
      map
      |> Enum.map(fn v ->
        [from, "(" <> to] = String.split(v, " = ")

        to = String.replace(to, ")", "")

        [to_left, to_right] = String.split(to, ", ")

        {from, {to_left, to_right}}
      end)
      |> Map.new()

    {instructions, map}
  end

  defp move({instructions, map}, current_nodes \\ nil, moved \\ 0) do
    current_nodes =
      if current_nodes == nil do
        map
        |> Map.keys()
        |> Enum.filter(fn k ->
          String.at(k, 2) == "A"
        end)
        |> Enum.map(fn k -> {k, nil} end)
      else
        current_nodes
      end

    if Enum.all?(current_nodes, fn {_, max} -> max != nil end) do
      Enum.reduce(current_nodes, fn {n, left}, {_, right} ->
        {n, trunc(left * right / Integer.gcd(left, right))}
      end)
    else
      instruction = String.at(instructions, rem(moved, String.length(instructions)))

      new_nodes =
        current_nodes
        |> Enum.map(fn {node, max_move} ->
          {left, right} = Map.get(map, node)

          next_node =
            case instruction do
              "L" -> left
              "R" -> right
            end

          max_move =
            if String.at(next_node, 2) == "Z" && max_move == nil do
              moved + 1
            else
              max_move
            end

          {next_node, max_move}
        end)

      move({instructions, map}, new_nodes, moved + 1)
    end
  end
end
