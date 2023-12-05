defmodule Day05P1 do
  def solve(filename) do
    File.read!(filename)
    |> String.trim()
    |> String.split("\n\n")
    |> map_input()
    |> Enum.min()
  end

  defp map_input(lines) do
    [seeds, seed_to_soil, soil_to_fertilizer, fertilizer_to_water, water_to_light, light_to_temperature, temperature_to_humidity, humidity_to_location] = lines

    "seeds: " <> seeds = seeds

    seeds = strings_to_nums(seeds)

    seed_to_soil = map_map(seed_to_soil)
    soil_to_fertilizer = map_map(soil_to_fertilizer)
    fertilizer_to_water = map_map(fertilizer_to_water)
    water_to_light = map_map(water_to_light)
    light_to_temperature = map_map(light_to_temperature)
    temperature_to_humidity = map_map(temperature_to_humidity)
    humidity_to_location = map_map(humidity_to_location)

    seeds
    |> Enum.map(&convert(&1, seed_to_soil))
    |> Enum.map(&convert(&1, soil_to_fertilizer))
    |> Enum.map(&convert(&1, fertilizer_to_water))
    |> Enum.map(&convert(&1, water_to_light))
    |> Enum.map(&convert(&1, light_to_temperature))
    |> Enum.map(&convert(&1, temperature_to_humidity))
    |> Enum.map(&convert(&1, humidity_to_location))
  end

  defp map_map(map) do
    [_name | rest] = String.split(map, "\n")

    Enum.map(rest, fn mapping ->
      [dest, source, length] = strings_to_nums(mapping)
      {Range.new(source, source + length - 1), dest - source}
    end)
  end

  defp convert(value, map) do
    Enum.reduce(map, value, fn {range, diff}, v ->
      if Enum.member?(range, value) do
        value + diff
      else
        v
      end
    end)
  end

  defp strings_to_nums(strings) do
    strings
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end
end
