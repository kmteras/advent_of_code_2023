defmodule Day09P2 do
  def solve(filename) do
    File.read!(filename)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn l ->
      l
      |> String.split()
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.map(&predict/1)
    |> Enum.sum()
  end

  defp predict(input) do
    first = Enum.at(input, 0)
    {increases, _last} = Enum.reduce(input, fn v, acc ->
      case acc do
        {list, last} ->
          {list ++ [v - last], v}

        last ->
          {[v - last], v}
      end
    end)

    if Enum.all?(increases, fn e -> e == 0 end) do
      first
    else
      first_from_predict = predict(increases)
      first - first_from_predict
    end
  end
end
