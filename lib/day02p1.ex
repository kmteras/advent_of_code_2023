defmodule Day02P1 do
  def solve(filename) do
    File.read!(filename)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&map_line/1)
    |> Enum.sum()
  end

  defp map_line(line) do
    ["Game " <> number | rounds] = String.split(line, [": ", "; "])

    if Enum.all?(rounds, &possible/1) do
      String.to_integer(number)
    else
      0
    end
  end

  defp possible(round) do
    String.split(round, ", ")
    |> Enum.all?(fn line ->
      [number, color] = String.split(line, " ")

      case color do
        "red" ->
          String.to_integer(number) <= 12

        "green" ->
          String.to_integer(number) <= 13

        "blue" ->
          String.to_integer(number) <= 14
      end
    end)
  end
end
