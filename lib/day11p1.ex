defmodule Day11P1 do
  def solve(filename) do
    File.read!(filename)
    |> String.trim()
    |> String.split("\n")
    |> grid_to_map()
    |> galaxies_and_expansion()
    |> distances()
  end

  defp distances({galaxies, expansions_width, expansions_height}) do
    galaxies
    |> Enum.flat_map(fn {{gx1, gy1}, _} ->
      galaxies
      |> Enum.map(fn {{gx2, gy2}, _} ->
        #        {{min(gx1, gx2), min(gy1, gy2), max(gx1, gx2), max(gy1, gy2)}, abs(gx1 - gx2) + abs(gy1 - gy2)}

        xc =
          expansions_width
          |> Enum.filter(fn x -> x > min(gx1, gx2) && x < max(gx1, gx2) end)
          |> Enum.count()

        yc =
          expansions_height
          |> Enum.filter(fn y -> y > min(gy1, gy2) && y < max(gy1, gy2) end)
          |> Enum.count()

        abs(gx1 - gx2) + abs(gy1 - gy2) + xc + yc
      end)
    end)
    #    |> Enum.uniq()
    |> Enum.sum()
    |> div()
  end

  defp div(v) do
    v / 2
  end

  defp galaxies_and_expansion(grid) do
    galaxies = Map.filter(grid, fn {_, v} -> v == "#" end)

    {{width, _}, _} = Enum.max_by(grid, fn {{x, _}, _v} -> x end)
    {{_, height}, _} = Enum.max_by(grid, fn {{_, y}, _v} -> y end)

    expansions_width =
      0..width
      |> Enum.filter(fn x ->
        0..height
        |> Enum.all?(fn y ->
          Map.get(grid, {x, y}) == "."
        end)
      end)

    expansions_height =
      0..height
      |> Enum.filter(fn y ->
        0..width
        |> Enum.all?(fn x ->
          Map.get(grid, {x, y}) == "."
        end)
      end)

    {galaxies, expansions_width, expansions_height}
  end

  defp grid_to_map(grid) do
    grid
    |> Enum.map(&String.graphemes/1)
    |> Enum.with_index()
    |> Enum.reduce(
      %{},
      fn {line, y}, map ->
        line
        |> Enum.with_index()
        |> Enum.reduce(
          %{},
          fn {risk, x}, map ->
            Map.put(map, {x, y}, risk)
          end
        )
        |> Map.merge(map)
      end
    )
  end
end
