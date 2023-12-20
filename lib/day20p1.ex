defmodule Day20P1 do
  def solve(filename) do
    File.read!(filename)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&map_input/1)
    |> Map.new()
    |> initialize_states()
    |> press_button()
    |> calculate()
  end

  def calculate({low_count, high_count, _}) do
    IO.inspect({low_count, high_count})
    low_count * high_count
  end

  defp press_button({modules, states}) do
    for _ <- 1..1000, reduce: {0, 0, states} do
      {low_count, high_count, states} ->
        {nlc, nhc, states} =
          send_pulses({modules, states}, [{"broadcaster", false, "button"}], 0, 0)

        {low_count + nlc, high_count + nhc, states}
    end
  end

  defp send_pulses({_, states}, [], low_count, high_count) do
    {low_count, high_count, states}
  end

  defp send_pulses(
         {modules, states},
         [{target, signal, origin} | target_queue],
         low_count,
         high_count
       ) do
    target_info = Map.get(modules, target)

    #    IO.inspect("#{origin} -#{signal}-> #{target}")

    {low_count, high_count} =
      if signal do
        {low_count, high_count + 1}
      else
        {low_count + 1, high_count}
      end

    if target_info == nil do
      send_pulses({modules, states}, target_queue, low_count, high_count)
    else
      #      IO.inspect(target_queue)

      {module_type, module_targets} = target_info

      {new_targets, states} =
        case module_type do
          :broad ->
            {Enum.map(module_targets, fn t -> {t, signal, target} end), states}

          :flip ->
            current_state = Map.get(states, target)

            if signal do
              {[], states}
            else
              new_state = !current_state

              {Enum.map(module_targets, fn t -> {t, new_state, target} end),
               Map.put(states, target, new_state)}
            end

          :conj ->
            related_states = Map.get(states, target)
            new_related_states = Map.put(related_states, origin, signal)

            send_signal =
              Map.values(new_related_states)
              |> Enum.all?()

            {Enum.map(module_targets, fn t -> {t, !send_signal, target} end),
             Map.put(states, target, new_related_states)}
        end

      send_pulses({modules, states}, target_queue ++ new_targets, low_count, high_count)
    end
  end

  defp initialize_states(modules) do
    {states, target_relations} =
      Enum.reduce(modules, {%{}, %{}}, fn {module_name, {module_type, targets}},
                                          {states, target_relations} ->
        target_relations =
          Enum.reduce(targets, target_relations, fn target, target_relations ->
            Map.update(target_relations, target, [module_name], fn existing ->
              [module_name] ++ existing
            end)
          end)

        states =
          case module_type do
            :broad ->
              states

            :flip ->
              Map.put(states, module_name, false)

            :conj ->
              states
          end

        {states, target_relations}
      end)

    states =
      Enum.reduce(modules, states, fn {module_name, {module_type, _}}, states ->
        if module_type == :conj do
          referencing = Map.get(target_relations, module_name)

          referencing_values =
            Enum.map(referencing, fn r -> {r, false} end)
            |> Map.new()

          Map.put(states, module_name, referencing_values)
        else
          states
        end
      end)

    {modules, states}
  end

  def map_input(input) do
    [module, targets] = String.split(input, " -> ")
    targets = String.split(targets, ", ")

    {module_type, module_name} =
      case String.at(module, 0) do
        "%" -> {:flip, String.slice(module, 1..-1)}
        "&" -> {:conj, String.slice(module, 1..-1)}
        _ -> {:broad, module}
      end

    {module_name, {module_type, targets}}
  end
end
