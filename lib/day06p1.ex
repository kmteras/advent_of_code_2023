defmodule Day06P1 do
  def solve(filename) do
    File.read!(filename)
    |> String.trim()
    |> String.split("\n")
    |> map_input()
    |> Enum.map(&Enum.count/1)
    |> Enum.product()
  end

  defp map_input(lines) do
    ["Time: " <> time, "Distance: " <> distance] = lines

    time = map_line(time)
    distance = map_line(distance)

    time
    |> Enum.with_index()
    |> Enum.map(fn {time, index} -> best_scores(time, Enum.at(distance, index)) end)
  end

  def best_scores(time, req_distance) do
    1..(time - 1)
    |> Enum.flat_map(fn t ->
      speed = t
      distance = (time - t) * speed

      if distance > req_distance do
        [t]
      else
        []
      end
    end)
  end

  def map_line(line) do
    line
    |> String.split(" ")
    |> Enum.map(&String.trim/1)
    |> Enum.filter(fn v -> v != "" end)
    |> Enum.map(&String.to_integer/1)
  end
end
