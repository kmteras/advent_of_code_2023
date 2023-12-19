defmodule Day19P2 do
  def solve(filename) do
    File.read!(filename)
    |> String.trim()
    |> String.split("\n\n")
    |> map_input()
    |> test_parts()
    |> score()
  end

  def score(part_ranges) do
    #    IO.inspect(4000 * 4000 * 4000 * 4000)

    part_ranges
    |> Enum.filter(fn {_, a} -> a == "A" end)
    |> Enum.map(fn {values, _} ->
      values
      |> Map.values()
      |> Enum.map(fn [l, r] -> r - l + 1 end)
      |> Enum.product()
    end)
    |> Enum.sum()
  end

  def test_parts(workflows) do
    test_workflow(workflows, [
      {%{"x" => [1, 4000], "m" => [1, 4000], "a" => [1, 4000], "s" => [1, 4000]}, "in"}
    ])
  end

  def test_workflow(workflows, part_combinations) do
    #    IO.inspect(part_combinations)

    new_ranges =
      part_combinations
      |> Enum.flat_map(fn {part_combination, target} ->
        if target == "A" || target == "R" do
          [{part_combination, target}]
        else
          wf = Map.get(workflows, target)

          Enum.reduce_while(wf, [part_combination], fn wf_step, all_pc ->
            {[continuing], rest} = Enum.split(all_pc, 1)

            case wf_step do
              {:condition, p, "<", v, t} ->
                [le, he] = Map.get(continuing, p)

                cond do
                  he < v ->
                    {:halt, [{continuing, t}] ++ rest}

                  le >= v ->
                    {:cont, all_pc}

                  le < v && he >= v ->
                    c_lt = Map.put(continuing, p, [le, v - 1])
                    c_gt = Map.put(continuing, p, [v, he])
                    {:cont, [c_gt, {c_lt, t}] ++ rest}
                end

              {:condition, p, ">", v, t} ->
                [le, he] = Map.get(continuing, p)

                cond do
                  le > v ->
                    {:halt, [{continuing, t}] ++ rest}

                  he <= v ->
                    {:cont, all_pc}

                  le <= v && he > v ->
                    c_lt = Map.put(continuing, p, [le, v])
                    c_gt = Map.put(continuing, p, [v + 1, he])
                    {:cont, [c_lt, {c_gt, t}] ++ rest}
                end

              {:target, t} ->
                {:halt, [{continuing, t}] ++ rest}
            end
          end)
        end
      end)

    if new_ranges != part_combinations do
      #      IO.inspect(new_ranges)
      test_workflow(workflows, new_ranges)
    else
      new_ranges
    end
  end

  def map_input([workflows, _]) do
    workflows =
      workflows
      |> String.split("\n")
      |> Enum.map(fn workflow ->
        [name, workflow] =
          workflow
          |> String.replace("}", "")
          |> String.split("{")

        workflow =
          workflow
          |> String.split(",")
          |> Enum.map(fn step ->
            case String.split(step, ":") do
              [condition, target] ->
                {_, value} = String.split_at(condition, 2)
                value = String.to_integer(value)
                part = String.at(condition, 0)
                condition = String.at(condition, 1)

                {:condition, part, condition, value, target}

              [target] ->
                {:target, target}
            end
          end)

        {name, workflow}
      end)
      |> Map.new()

    workflows
  end
end
