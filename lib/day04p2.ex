defmodule Day04P2 do
  def solve(filename) do
    File.read!(filename)
    |> String.trim()
    |> String.split("\n")
    |> Enum.reduce(%{}, &map_line/2)
    |> Map.values()
    |> Enum.sum()
  end

  defp map_line(line, acc) do
    ["Card " <> n, rest] = String.split(line, ": ")

    n = String.to_integer(String.trim(n))

    [winning, yours] = String.split(rest, " | ")

    winning = Enum.filter(String.split(winning, " "), fn a -> a != "" end)
    yours = String.split(yours, " ")

    common = Enum.count(MapSet.intersection(MapSet.new(winning), MapSet.new(yours)))

    if common == 0 do
      Map.merge(acc, Map.new([{n, 1}]), fn k, a, b -> a + b end)
    else
      range = Enum.to_list(Range.new(n + 1, n + common))

      new_count = Map.new(range, fn nv -> {nv, Map.get(acc, n, 0) + 1} end)
      new_count = Map.put(new_count, n, 1)

      Map.merge(acc, new_count, fn k, a, b -> a + b end)
    end
  end
end
