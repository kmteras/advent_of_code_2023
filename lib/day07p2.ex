defmodule Day07P2 do
  def solve(filename) do
    File.read!(filename)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&map_input/1)
    |> Enum.sort_by(fn {s, {_r, rs}, _, _} -> {rs, s} end)
    |> Enum.with_index()
    |> Enum.map(fn {{_, _, _, bid}, index} -> (index + 1) * bid end)
    |> Enum.sum()
  end

  defp map_input(lines) do
    [hand, bid] = String.split(lines, " ")

    bid = String.to_integer(bid)

    type =
      hand
      |> String.graphemes()
      |> Enum.frequencies()
      |> map_type()

    strength =
      hand
      |> String.replace("A", "D")
      |> String.replace("T", "A")
      |> String.replace("J", "1")
      |> String.replace("Q", "B")
      |> String.replace("K", "C")
      |> String.to_integer(14)

    {strength, type, hand, bid}
  end

  defp map_type(frequencies) do
    values =
      frequencies
      |> Map.values()
      |> Enum.sort(:desc)

    j_count = Map.get(frequencies, "J", 0)

    case {values, j_count} do
      {[5], 0} -> {:five, 7}
      {[5], 5} -> {:five, 7}
      {[4, 1], 1} -> {:five, 7}
      {[4, 1], 4} -> {:five, 7}
      {[3, 2], 2} -> {:five, 7}
      {[3, 2], 3} -> {:five, 7}
      {[4, 1], 0} -> {:four, 6}
      {[3, 1, 1], 1} -> {:four, 6}
      {[3, 1, 1], 3} -> {:four, 6}
      {[2, 2, 1], 2} -> {:four, 6}
      {[3, 2], 0} -> {:full, 5}
      {[2, 2, 1], 1} -> {:full, 5}
      {[3, 1, 1], 0} -> {:three, 4}
      {[2, 1, 1, 1], 1} -> {:three, 4}
      {[2, 1, 1, 1], 2} -> {:three, 4}
      {[2, 2, 1], 0} -> {:two, 3}
      {[2, 1, 1, 1], 0} -> {:one, 2}
      {[1, 1, 1, 1, 1], 1} -> {:one, 2}
      {[1, 1, 1, 1, 1], 0} -> {:high, 1}
    end
  end
end
