defmodule Day25P1 do
  def solve(filename) do
    File.read!(filename)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&map_line/1)
    |> Map.new()
    |> map_info()
    #    |> IO.inspect()
    |> minimal_cut()
  end

  defp map_info(links) do
    set =
      Enum.reduce(links, MapSet.new(), fn {f, val}, set ->
        set = MapSet.put(set, f)
        MapSet.union(set, MapSet.new(val))
      end)

    map_size = Enum.count(set)

    links =
      Enum.reduce(links, Map.new(), fn {f, val}, map ->
        l = MapSet.new(val)
        map = Map.update(map, f, l, fn r -> MapSet.union(l, r) end)

        Enum.reduce(val, map, fn v, map ->
          l = MapSet.new([f])

          IO.puts("G.add_edge(\"#{f}\", \"#{v}\")")

          Map.update(map, v, l, fn r -> MapSet.union(l, r) end)
        end)
      end)

    group_size(links)
    |> IO.inspect()

    {links, map_size}
  end

  defp minimal_cut({links, _}) do
    vertices = Map.keys(links)

    edges =
      Enum.flat_map(links, fn {v, keys} ->
        Enum.map(keys, fn k -> {v, k} end)
      end)

    subsets =
      Enum.map(vertices, fn v ->
        MapSet.new([v])
      end)

    do_min_cut(links, Enum.count(vertices), edges, subsets)
  end

  defp do_min_cut(links, vertices, edges, subsets) do
    if vertices > 2 do
      random_edge_n = :rand.uniform(Enum.count(edges)) - 1
      {v1, v2} = Enum.at(edges, random_edge_n)

      edge1_ss =
        Enum.find(subsets, fn subset ->
          MapSet.member?(subset, v1)
        end)

      edge2_ss =
        Enum.find(subsets, fn subset ->
          MapSet.member?(subset, v2)
        end)

      {vertices, subsets} =
        if edge1_ss == edge2_ss do
          {vertices, subsets}
        else
          subsets = List.delete(subsets, edge1_ss)
          subsets = List.delete(subsets, edge2_ss)

          subsets = [MapSet.union(edge1_ss, edge2_ss)] ++ subsets
          {vertices - 1, subsets}
        end

      do_min_cut(links, vertices, edges, subsets)
    else
      {subsets}
    end
  end

  defp group_size(links) do
    first = Enum.at(Map.keys(links), 0)

    group_size(links, first, MapSet.new())
    |> Enum.count()
  end

  defp group_size(links, from, visited) do
    v = Map.get(links, from, [])
    visited = MapSet.put(visited, from)

    Enum.reduce(v, visited, fn new_v, visited ->
      if !MapSet.member?(visited, new_v) do
        group_size(links, new_v, visited)
      else
        visited
      end
    end)
  end

  defp map_line(line) do
    [g, groups] = String.split(line, ": ")

    groups = MapSet.new(String.split(groups, " "))
    {g, groups}
  end
end
