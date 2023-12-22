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

    l = :ets.tab2list(:memory2)

    cycle_length = 131
    #    cycle_length = 11

    want_index = 26_501_365

    chunked = Enum.chunk_every(l, cycle_length, cycle_length, :discard)

    cycle_offsets =
      chunked
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn [[{_, v} | _], [{_, v2} | _]] ->
        v2 - v
      end)

    #    |> IO.inspect()

    cycle_offsets_offsets =
      cycle_offsets
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn [f, s] ->
        s - f
      end)

    #     |> IO.inspect()

    last_complete = Enum.at(chunked, -2)

    [{start_i, start_v} | _] = last_complete

    cycles = floor((want_index - start_i) / cycle_length)
    shift = rem(want_index - start_i, cycle_length)

    IO.inspect({cycles, shift})

    IO.inspect(chunked)

    new_cycle_value =
      start_v + Enum.at(cycle_offsets, -2) * cycles +
        Enum.at(cycle_offsets_offsets, -1) * floor(cycles * (cycles + 1) / 2)

    shift_offsets = shift_at(chunked, shift)

    IO.inspect(shift_offsets)

    shift_offset_offsets =
      shift_offsets
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn [f, s] ->
        s - f
      end)
      |> IO.inspect()

    IO.inspect(
      {Enum.at(shift_offsets, -2), Enum.at(shift_offset_offsets, -2),
       floor(cycles * (cycles + 1) / 2)}
    )

    # 648
    # 648 + 14 * 20

    new_value =
      new_cycle_value + Enum.at(shift_offsets, -2) + Enum.at(shift_offset_offsets, -2) * cycles

    IO.inspect(
      {start_i + cycles * cycle_length, new_cycle_value, start_i + cycles * cycle_length + shift,
       new_value}
    )

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

  defp look_for_neighbors(info, lookup_positions \\ nil, steps \\ 0)

  defp look_for_neighbors(_, current_positions, steps = 500) do
    [{_day, {from, _}}] = :ets.lookup(:memory, rem(steps, 2))

    Enum.count(current_positions) + Enum.count(from)
  end

  defp look_for_neighbors({width, height, grid}, lookup_positions, steps) do
    if rem(steps, 10000) == 0 do
      IO.inspect(steps)
    end

    lookup_positions =
      if lookup_positions == nil do
        {p, _} = Enum.find(grid, fn {_, v} -> v == "S" end)
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

    {n_from, _} =
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

              {npx, npy} = {rem(px, width), rem(py, height)}

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

    IO.puts("#{steps}\t#{Enum.count(lookup_positions) + Enum.count(from)}")

    :ets.insert(:memory2, {steps, Enum.count(lookup_positions) + Enum.count(from)})

    #    new_positions = MapSet.union(new_positions, to)

    :ets.insert(
      :memory,
      {rem(steps, 2), {MapSet.union(from, lookup_positions), MapSet.union(new_positions, to)}}
    )

    look_for_neighbors({width, height, grid}, new_positions, steps + 1)
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
