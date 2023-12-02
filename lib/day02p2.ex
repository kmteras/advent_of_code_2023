defmodule Day02P2 do
  def solve(filename) do
    File.read!(filename)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&map_line/1)
    |> Enum.sum()
  end

  defp map_line(line) do
    ["Game " <> _number | rounds] = String.split(line, [": ", "; "])

    rounds
    |> Enum.reduce([0, 0, 0], &possible/2)
    |> Enum.product()
  end

  defp possible(round, acc) do
    round
    |> String.split(", ")
    |> Enum.reduce(acc, fn line, [r, g, b] ->
      [number, color] = String.split(line, " ")

      case color do
        "red" ->
          [max(r, String.to_integer(number)), g, b]

        "green" ->
          [r, max(g, String.to_integer(number)), b]

        "blue" ->
          [r, g, max(b, String.to_integer(number))]
      end
    end)
  end
end
