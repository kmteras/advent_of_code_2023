defmodule Day01P1 do

  def solve(filename) do
    File.read!(filename)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&digits/1)
    |> Enum.sum()
  end

  defp digits(list) do
    case Regex.scan(~r/(\d).*(\d)/, list) do
      [[_, first, last]] -> String.to_integer(first <> last)
      [] ->
        [[_, first]] = Regex.scan(~r/(\d)/, list)
        String.to_integer(first <> first)
    end
  end
end
