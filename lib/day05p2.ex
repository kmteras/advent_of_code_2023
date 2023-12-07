defmodule Day05P2 do
  def solve(filename) do
    File.read!(filename)
    |> String.trim()
    |> String.split("\n\n")
    |> map_input()
    |> Enum.map(&Enum.min/1)
    |> Enum.min()
  end

  defp map_input(lines) do
    [
      seeds,
      seed_to_soil,
      soil_to_fertilizer,
      fertilizer_to_water,
      water_to_light,
      light_to_temperature,
      temperature_to_humidity,
      humidity_to_location
    ] = lines

    "seeds: " <> seeds = seeds

    seeds =
      seeds
      |> strings_to_nums()
      |> Enum.chunk_every(2)
      |> Enum.map(fn [start, length] -> Range.new(start, start + length - 1) end)

    seed_to_soil = map_map(seed_to_soil)
    soil_to_fertilizer = map_map(soil_to_fertilizer)
    fertilizer_to_water = map_map(fertilizer_to_water)
    water_to_light = map_map(water_to_light)
    light_to_temperature = map_map(light_to_temperature)
    temperature_to_humidity = map_map(temperature_to_humidity)
    humidity_to_location = map_map(humidity_to_location)

    seeds
    |> Enum.flat_map(&convert(&1, seed_to_soil))
    |> Enum.flat_map(&convert(&1, soil_to_fertilizer))
    |> Enum.flat_map(&convert(&1, fertilizer_to_water))
    |> Enum.flat_map(&convert(&1, water_to_light))
    |> Enum.flat_map(&convert(&1, light_to_temperature))
    |> Enum.flat_map(&convert(&1, temperature_to_humidity))
    |> Enum.flat_map(&convert(&1, humidity_to_location))
  end

  defp map_map(map) do
    [_name | rest] = String.split(map, "\n")

    Enum.map(rest, fn mapping ->
      [dest, source, length] = strings_to_nums(mapping)
      {Range.new(source, source + length - 1), dest - source}
    end)
  end

  defp convert(value, map) do
    Enum.reduce(map, [{:old, value}], fn {map_start..map_end, diff}, values ->
      Enum.flat_map(values, fn {type, s..e = range} ->
        cond do
          type == :new ->
            [{type, range}]

          s >= map_start && e <= map_end ->
            [{:new, Range.shift(range, diff)}]

          s < map_start && e <= map_end && e >= map_start ->
            [{:old, Range.new(s, map_start - 1)}, {:new, Range.new(map_start + diff, e + diff)}]

          e > map_end && s >= map_start && s <= map_end ->
            [{:new, Range.new(s + diff, map_end - 1 + diff)}, {:old, Range.new(map_end, e)}]

          s < map_start && e > map_end ->
            [
              {:old, Range.new(s, map_start - 1)},
              {:new, Range.new(map_start + diff, map_end + diff)},
              {:old, Range.new(map_end + 1, e)}
            ]

          true ->
            [{:old, range}]
        end
      end)
    end)
    |> Enum.map(fn {_, range} -> range end)
  end

  defp strings_to_nums(strings) do
    strings
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end
end
