defmodule Day04P1 do
  def solve(filename) do
    File.read!(filename)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&map_line/1)
    |> Enum.sum()
  end

  defp map_line(line) do
    ["Card " <> n, rest] = String.split(line, ": ")

    [winning, yours] = String.split(rest, " | ")

    winning = Enum.filter(String.split(winning, " "), fn a -> a != "" end)
    yours = String.split(yours, " ")

    common = Enum.count(MapSet.intersection(MapSet.new(winning), MapSet.new(yours)))

    if common == 0 do
      0
    else
      :math.pow(2, common - 1)
    end
  end
end
