defmodule Day08P1 do
  def solve(filename) do
    File.read!(filename)
    |> String.trim()
    |> String.split("\n\n")
    |> map_input()
    |> move()
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

  defp move(_, current_node \\ "AAA", moved \\ 0)

  defp move(_, "ZZZ", moved) do
    moved
  end

  defp move({instructions, map}, current_node, moved) do
    instruction = String.at(instructions, rem(moved, String.length(instructions)))

    {left, right} = Map.get(map, current_node)

    next_node =
      case instruction do
        "L" -> left
        "R" -> right
      end

    move({instructions, map}, next_node, moved + 1)
  end
end
