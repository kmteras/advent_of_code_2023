defmodule Day15P2 do
  def solve(filename) do
    File.read!(filename)
    |> String.trim()
    |> String.split("\n")
    |> Enum.at(0)
    |> String.split(",")
    |> Enum.reduce(Map.new(), &parse/2)
    |> Enum.map(fn {box, values} ->
      values
      |> Enum.with_index()
      |> Enum.map(fn {{_, focal}, index} ->
        (box + 1) * (index + 1) * focal
      end)
      |> Enum.sum()
    end)
    |> Enum.sum()
  end

  defp parse(line, acc) do
    line = String.graphemes(line)

    if List.last(line) != "-" do
      index = String.to_integer(List.last(line))

      label_chars = Enum.take(line, Enum.count(line) - 2)

      label = Enum.join(label_chars, "")
      box_no = Enum.reduce(label_chars, 0, &hash/2)

      Map.update(acc, box_no, [{label, index}], fn existing ->
        if Enum.find(existing, fn {l, _} -> l == label end) do
          Enum.map(existing, fn {l, v} ->
            if l == label do
              {label, index}
            else
              {l, v}
            end
          end)
        else
          existing ++ [{label, index}]
        end
      end)
    else
      label =
        line
        |> Enum.take(Enum.count(line) - 1)
        |> Enum.join("")

      acc
      |> Enum.map(fn {index, values} ->
        values = Enum.filter(values, fn {l, _} -> l != label end)
        {index, values}
      end)
      |> Map.new()
    end
  end

  defp hash(character, acc) do
    <<v::utf8>> = character
    rem((acc + v) * 17, 256)
  end
end
