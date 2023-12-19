defmodule Day19P1 do
  def solve(filename) do
    File.read!(filename)
    |> String.trim()
    |> String.split("\n\n")
    |> map_input()
    |> test_parts()
    |> Enum.sum()
  end

  def test_parts({workflows, parts}) do
    Enum.map(parts, fn part ->
      if test_workflow(workflows, part, "in") == "A" do
        part
        |> Map.values()
        |> Enum.sum()
      else
        0
      end
    end)
  end

  # in

  def test_workflow(workflows, part, workflow) do
    wf = Map.get(workflows, workflow)

    next_step =
      Enum.reduce_while(wf, "", fn wf_step, _ ->
        case wf_step do
          {:condition, p, "<", v, n} ->
            if Map.get(part, p) < v do
              {:halt, n}
            else
              {:cont, n}
            end

          {:condition, p, ">", v, n} ->
            if Map.get(part, p) > v do
              {:halt, n}
            else
              {:cont, n}
            end

          {:target, n} ->
            {:halt, n}
        end
      end)

    if next_step != "A" && next_step != "R" do
      test_workflow(workflows, part, next_step)
    else
      next_step
    end
  end

  def map_input([workflows, parts]) do
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

    parts =
      parts
      |> String.split("\n")
      |> Enum.map(fn part_line ->
        part_line
        |> String.replace("{", "")
        |> String.replace("}", "")
        |> String.split(",")
        |> Enum.map(fn part ->
          [p, v] = String.split(part, "=")
          {p, String.to_integer(v)}
        end)
        |> Map.new()
      end)

    {workflows, parts}
  end
end
