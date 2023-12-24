defmodule Day24P1 do
  def solve(filename) do
    File.read!(filename)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&map_line/1)
#    |> check_intersections(7, 27)
    |> check_intersections(200000000000000, 400000000000000)
    |> ans()
  end

  defp ans(intersections) do
    Enum.count(intersections) / 2
  end

  defp check_intersections(lines, s, e) do
    lines
    |> Enum.flat_map(fn {{x1, y1, _z1}, {vx1, vy1, _vz1}} = l1 ->
      Enum.flat_map(lines, fn {{x2, y2, _z2}, {vx2, vy2, _vz2}} = l2 ->
        if l1 != l2 do
          det = vx1 * vy2 - vy1 * vx2

          if det != 0 do
            u = (y1 * vx2 + vy2 * x2 - y2 * vx2 - vy2 * x1) / det
            v = (x1 + vx1 * u - x2) / vx2

            if u > 0 && v > 0 do
              m1 = (y1 + vy1 - y1) / (x1 + vx1 - x1)
              m2 = (y2 + vy2 - y2) / (x2 + vx2 - x2)

              b1 = y1 - m1 * x1
              b2 = y2 - m2 * x2

              x = (b2 - b1) / (m1 - m2)
              y = m1 * x + b1

              if x >= s && x <= e && y >= s && y <= e do
                [{l1, l2}]
              else
                []
              end
            else
              []
            end
          else
            []
          end
        else
          []
        end
      end)
    end)
  end

  defp map_line(line) do
    line = String.replace(line, " @ ", ", ")
    [x, y, z, vx, vy, vz] = line
                            |> String.split(", ")
                            |> Enum.map(&String.trim/1)
                            |> Enum.filter(fn v -> v != "" end)
                            |> Enum.map(&String.to_integer/1)

    {{x, y, z}, {vx, vy, vz}}
  end
end
