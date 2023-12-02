defmodule Day01P2 do
  def solve(filename) do
    File.read!(filename)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&digits/1)
    |> Enum.sum()
  end

  defp digits(list) do
    case Regex.scan(
           ~r/(\d|one|two|three|four|five|six|seven|eight|nine).*(\d|one|two|three|four|five|six|seven|eight|nine)/,
           list
         ) do
      [[_, first, last]] ->
        String.to_integer(to_int(first) <> to_int(last))

      [] ->
        [[_, first]] = Regex.scan(~r/(\d|one|two|three|four|five|six|seven|eight|nine)/, list)
        String.to_integer(to_int(first) <> to_int(first))
    end
  end

  defp to_int(text) do
    case text do
      "one" -> "1"
      "two" -> "2"
      "three" -> "3"
      "four" -> "4"
      "five" -> "5"
      "six" -> "6"
      "seven" -> "7"
      "eight" -> "8"
      "nine" -> "9"
      _ -> text
    end
  end
end
