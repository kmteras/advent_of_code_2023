defmodule Day12P1 do
  import Bitwise

  def solve(filename) do
    File.read!(filename)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&map_input/1)
    |> Enum.map(&arrangements/1)
    |> Enum.sum()
  end

  defp map_input(list) do
    [springs, row] = String.split(list, " ")

    row =
      String.split(row, ",")
      |> Enum.map(&String.to_integer/1)

    {springs, row}
  end

  defp arrangements({springs, row}) do
    comb_count =
      springs
      |> String.replace(".", "")
      |> String.replace("#", "")
      |> String.length()

    0..round(:math.pow(2, comb_count) - 1)
    |> Enum.flat_map(fn n -> map_arrangement(n, springs, row) end)
    |> Enum.count()
  end

  defp map_arrangement(n, spring, row) do
    ans =
      spring
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {v, index} ->
        index =
          spring
          |> String.slice(0, index)
          |> String.replace(".", "")
          |> String.replace("#", "")
          |> String.length()

        case v do
          "#" ->
            "#"

          "." ->
            "."

          "?" ->
            if band(n, round(:math.pow(2, index))) != 0 do
              "#"
            else
              "."
            end
        end
      end)

    if valid?({ans, row}) do
      [ans]
    else
      []
    end
  end

  defp valid?({springs, row}) do
    sorted_springs =
      Enum.join(springs, "")
      |> String.split(".")
      |> Enum.filter(fn v -> v != "" end)
      |> Enum.map(&String.length/1)

    sorted_springs == row
  end
end
