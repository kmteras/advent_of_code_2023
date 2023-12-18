defmodule Day18P2 do
  def solve(filename) do
    File.read!(filename)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&map_input/1)
    |> Enum.reduce({[], 0, {0, 0}}, &dig/2)
    #    |> order_clockwise()
    |> shoelace()
  end

  def order_clockwise({dug, lines, _}) do
    center = calculate_center(dug)

    sorted = Enum.sort_by(dug, &angle_from_center(&1, center))
    {sorted, lines, nil}
  end

  def angle_from_center({x, y}, {cx, cy}) do
    :math.atan2(y - cy, x - cx)
  end

  def calculate_center(dug) do
    count = Enum.count(dug)

    {x_sum, y_sum} =
      for {x, y} <- dug, reduce: {0, 0} do
        {x_sum, y_sum} -> {x_sum + x, y_sum + y}
      end

    {x_sum / count, y_sum / count}
  end

  def shoelace({dug, lines, _}) do
    first = Enum.at(dug, 0)

    ans =
      dug
      |> Enum.chunk_every(2, 1, [first])
      |> Enum.map(fn [{x1, y1}, {x2, y2}] ->
        x1 * y2 - x2 * y1
      end)
      |> Enum.sum()
      |> abs()

    shoelace = ans / 2

    # Pick's
    shoelace + lines / 2 + 1
  end

  def dig({direction, amount}, {dug, lines, {x, y}}) do
    {ox, oy} = {x, y}

    new_coord =
      case direction do
        "U" -> {ox, oy - amount}
        "D" -> {ox, oy + amount}
        "R" -> {ox + amount, oy}
        "L" -> {ox - amount, oy}
      end

    {[new_coord] ++ dug, lines + amount, new_coord}
  end

  def map_input(input) do
    [_direction, _amount, color] = String.split(input, " ")

    {amount, direction} =
      color
      |> String.replace("(", "")
      |> String.replace(")", "")
      |> String.replace("#", "")
      |> String.split_at(5)

    direction =
      case direction do
        "0" -> "R"
        "1" -> "D"
        "2" -> "L"
        "3" -> "U"
      end

    amount = String.to_integer(amount, 16)
    {direction, amount}
  end
end
