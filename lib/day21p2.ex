defmodule Day21P2 do
  def solve(filename) do
    # 86257167077887936

    :ets.new(:memory, [:set, :public, :named_table])
    :ets.new(:memory2, [:ordered_set, :public, :named_table])

    File.read!(filename)
    |> String.trim()
    |> String.split("\n")
    |> grid_to_map()
    |> grid_info()
    |> look_for_neighbors()

    start_cycle = 475
    cycle_start = 150538
    cycle_length = 11

    n = 3
#    n = 3
    shift = 8

    wanted_cycle = 1000

    IO.inspect("n: #{floor((wanted_cycle - start_cycle) / cycle_length)}")
    IO.inspect("shift: #{rem(wanted_cycle - start_cycle, cycle_length)}")

    cycle_diff = 7066
    cycle_diff_diff = 162

    moved_cycles = start_cycle + n * cycle_length + shift
    new_cycle_value = cycle_start + cycle_diff * n + cycle_diff_diff * of(n - 1)

    # Precalculated for a increase of 3
#    cycle_shift = 2076
#    cycle_shift_shift = 48

    # Precalculated for a increase of 8
    cycle_shift = 5369
    cycle_shift_shift = 121

    # 5611

    # 7552
    # 7390
    # 7228
    # 7066

    new_shift = new_cycle_value + cycle_shift + cycle_shift_shift * (n - 1)

    l = :ets.tab2list(:memory2)

    cycle_length = 131
#    cycle_length = 11

    want_index = 26501365

    chunked = Enum.chunk_every(l, cycle_length, cycle_length, :discard)

    cycle_offsets = chunked
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [[{_, v} | _], [{_, v2} | _]] ->
      v2 - v
    end)
#    |> IO.inspect()

    cycle_offsets_offsets = cycle_offsets
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [f, s] ->
      s - f
    end)
#     |> IO.inspect()

    a = chunked
        |> Enum.map(fn list ->
      (elem(Enum.at(list, 1), 1)) - elem(Enum.at(list, 0), 1)
    end)
#        |> IO.inspect()
        |> Enum.chunk_every(2, 1, :discard)
        |> Enum.map(fn [f, s] ->
      s - f
    end)
#    |> IO.inspect()

    last_complete = Enum.at(chunked, -2)

    [{start_i, start_v} | _] = last_complete

    cycles = floor((want_index - start_i) / cycle_length)
    shift = rem(want_index - start_i, cycle_length)

    IO.inspect({cycles, shift})

    IO.inspect(chunked)

    new_cycle_value = start_v + Enum.at(cycle_offsets, -2) * cycles + Enum.at(cycle_offsets_offsets, -1) * floor(((cycles) * (cycles + 1) / 2))

    shift_offsets = shift_at(chunked, shift)

    IO.inspect(shift_offsets)

    shift_offset_offsets = shift_offsets
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [f, s] ->
      s - f
    end)
    |> IO.inspect()

    IO.inspect({Enum.at(shift_offsets, -2), Enum.at(shift_offset_offsets, -2), floor(((cycles) * (cycles + 1) / 2))})

    # 648
    # 648 + 14 * 20

    new_value = new_cycle_value + Enum.at(shift_offsets, -2) + Enum.at(shift_offset_offsets, -2) * cycles

    IO.inspect({start_i + cycles * cycle_length, new_cycle_value, start_i + cycles * cycle_length + shift, new_value})

#    IO.inspect({moved_cycles, new_shift, start_cycle + n * cycle_length, new_cycle_value})
  end

  def shift_at(chunked, shift) do
    chunked
    |> Enum.map(fn list ->
      elem(Enum.at(list, shift), 1) - elem(Enum.at(list, 0), 1)
    end)
  end

  def of(0), do: 1
  def of(n) when n > 0 do
    Enum.reduce(1..n, &*/2)
  end

  defp grid_info(grid) do
    {{width, _}, _} = Enum.max_by(grid, fn {{x, _}, _} -> x end)
    {{_, height}, _} = Enum.max_by(grid, fn {{_, y}, _} -> y end)

    {width + 1, height + 1, grid}
  end

  defp look_for_neighbors(_, current_positions, steps = 500) do
    [{_day, {from, to}}] = :ets.lookup(:memory, rem(steps, 2))

    Enum.count(current_positions) + Enum.count(from)
  end

  defp look_for_neighbors({width, height, grid}, lookup_positions \\ nil, steps \\ 0) do
    if rem(steps, 10000) == 0 do
      IO.inspect(steps)
    end

    lookup_positions =
      if lookup_positions == nil do
        {p, _} = Enum.find(grid, fn {p, v} -> v == "S" end)
        MapSet.new([p])
      else
        lookup_positions
      end

    {from, to} =
      case :ets.lookup(:memory, rem(steps, 2)) do
        [{_day, {from, to}}] ->
          {from, to}

        [] ->
          {MapSet.new(), MapSet.new()}
      end

    {n_from, n_to} =
      case :ets.lookup(:memory, rem(steps + 1, 2)) do
        [{_day, {from, to}}] ->
          {from, to}

        [] ->
          {MapSet.new(), MapSet.new()}
      end

    new_positions =
      for {x, y} <- lookup_positions, reduce: MapSet.new() do
        new_positions ->
          for {dx, dy} <- [{-1, 0}, {1, 0}, {0, -1}, {0, 1}], reduce: new_positions do
            new_positions ->
              {px, py} = p = {x + dx, y + dy}

              {npx, npy} = normalized_p = {rem(px, width), rem(py, height)}

              normalized_p =
                cond do
                  npx < 0 && npy < 0 -> {width + npx, height + npy}
                  npx < 0 -> {width + npx, npy}
                  npy < 0 -> {npx, height + npy}
                  true -> {npx, npy}
                end

              if Map.has_key?(grid, normalized_p) && !MapSet.member?(n_from, p) do
                MapSet.put(new_positions, p)
              else
                new_positions
              end
          end
      end

    normalized_count =
      normalize(width, height, lookup_positions)
      |> MapSet.new()
      |> Enum.count()

    normalized_new_positions_count =
      normalize(width, height, new_positions)
      |> MapSet.new()
      |> Enum.count()

#    IO.inspect(
#      {steps,
#        Enum.count(new_positions) - Enum.count(lookup_positions),
#        normalized_count, normalized_new_positions_count,
#       Enum.count(lookup_positions), Enum.count(new_positions),
#        Enum.count(lookup_positions) + Enum.count(from)
#      }
#    )

        IO.puts(
          "#{steps}\t#{Enum.count(lookup_positions) + Enum.count(from)}"
        )

    :ets.insert(:memory2, {steps, Enum.count(lookup_positions) + Enum.count(from)})

    #    new_positions = MapSet.union(new_positions, to)

    :ets.insert(
      :memory,
      {rem(steps, 2), {MapSet.union(from, lookup_positions), MapSet.union(new_positions, to)}}
    )

    look_for_neighbors({width, height, grid}, new_positions, steps + 1)
  end

  defp normalize(width, height, lookup_positions) do
    Enum.map(lookup_positions, fn {x, y} ->
      {npx, npy} = normalized_p = {rem(x, width), rem(y, height)}

      normalized_p =
        cond do
          npx < 0 && npy < 0 -> {width + npx, height + npy}
          npx < 0 -> {width + npx, npy}
          npy < 0 -> {npx, height + npy}
          true -> {npx, npy}
        end
    end)
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
            if risk != "#" do
              Map.put(map, {x, y}, risk)
            else
              map
            end
          end
        )
        |> Map.merge(map)
      end
    )
  end
end
