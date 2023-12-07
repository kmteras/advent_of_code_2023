defmodule Day07P1 do
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
      |> String.replace("A", "E")
      |> String.replace("T", "A")
      |> String.replace("J", "B")
      |> String.replace("Q", "C")
      |> String.replace("K", "D")
      |> String.to_integer(15)

    {strength, type, hand, bid}
  end

  defp map_type(frequencies) do
    values =
      frequencies
      |> Map.values()
      |> Enum.sort(:desc)

    case values do
      [5] -> {:five, 7}
      [4, 1] -> {:four, 6}
      [3, 2] -> {:full, 5}
      [3, 1, 1] -> {:three, 4}
      [2, 2, 1] -> {:two, 3}
      [2, 1, 1, 1] -> {:one, 2}
      [1, 1, 1, 1, 1] -> {:high, 1}
    end
  end
end
