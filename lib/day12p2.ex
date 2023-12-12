defmodule Day12P2 do
  def solve(filename) do
    :ets.new(:memory, [:set, :public, :named_table])

    File.read!(filename)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&map_input/1)
    |> Enum.map(&arrangements/1)
    |> Enum.sum()
  end

  defp map_input(list) do
    [springs, row] = String.split(list, " ")

    springs = springs <> "?" <> springs <> "?" <> springs <> "?" <> springs <> "?" <> springs
    row = row <> "," <> row <> "," <> row <> "," <> row <> "," <> row

    row =
      String.split(row, ",")
      |> Enum.map(&String.to_integer/1)

    {springs, row}
  end

  defp arrangements({"", row}) do
    if Enum.count(row) == 0 do
      1
    else
      0
    end
  end

  defp arrangements({springs, row}) do
    {first, rest} = String.split_at(springs, 1)

    case first do
      "." ->
        arrangements({rest, row})

      "#" ->
        res = first_hash({springs, row})

        :ets.insert(:memory, {{springs, row}, res})

        res

      "?" ->
        res = first_hash({springs, row})

        :ets.insert(:memory, {{springs, row}, res})

        arrangements({rest, row}) + res
    end
  end

  defp first_hash({springs, row} = params) do
    case :ets.lookup(:memory, params) do
      [{_params, ans}] ->
        ans

      [] ->
        [row_first | row_rest] = row

        {spring_start, spring_rest} = String.split_at(springs, row_first)

        cond do
          # Look at string contains .
          String.replace(spring_start, ["#", "?"], "") != "" ->
            0

          # Looked at string is smaller than required
          String.length(spring_start) < row_first ->
            0

          # Rows match but next character is continuation
          String.length(spring_start) == row_first && String.at(spring_rest, 0) == "#" ->
            0

          # Rows match and out of new candidates but # remain
          String.length(spring_start) == row_first && Enum.count(row_rest) == 0 &&
              String.replace(spring_rest, [".", "?"], "") != "" ->
            0

          # Rows match
          String.length(spring_start) == row_first && Enum.count(row_rest) == 0 ->
            1

          # Less characters left than required
          String.length(spring_rest) < Enum.sum(row_rest) + Enum.count(row_rest) - 1 ->
            0

          true ->
            arrangements({String.slice(spring_rest, 1, String.length(spring_rest) - 1), row_rest})
        end
    end
  end
end
