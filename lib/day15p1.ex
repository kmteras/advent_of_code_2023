defmodule Day15P1 do
  def solve(filename) do
    File.read!(filename)
    |> String.trim()
    |> String.split("\n")
    |> Enum.at(0)
    |> String.split(",")
    |> Enum.map(&parse/1)
    |> Enum.sum()
  end

  defp parse(line) do
    line
    |> String.graphemes()
    |> Enum.reduce(0, &hash/2)
  end

  defp hash(character, acc) do
    <<v::utf8>> = character
    rem((acc + v) * 17, 256)
  end
end
