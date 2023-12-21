defmodule Day20P2 do
  def solve(filename) do
    File.read!(filename)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&map_input/1)
    |> Map.new()
    |> initialize_states()
    |> press_button()
    |> Map.values()
    |> Enum.reduce(&lcm/2)
  end

  defp lcm(left, right) do
    trunc(left * right / Integer.gcd(left, right))
  end

  defp press_button({modules, states, to_observe}) do
    Enum.reduce_while(1..10_000_000, {states, Map.new(to_observe, fn v -> {v, nil} end)}, fn i,
                                                                                             {states,
                                                                                              observations} ->
      {states, observations} =
        send_pulses({modules, states}, [{"broadcaster", false, "button"}], i, observations)

      if Enum.all?(Map.values(observations)) do
        {:halt, observations}
      else
        {:cont, {states, observations}}
      end
    end)
  end

  defp send_pulses({_, states}, [], _, observations) do
    {states, observations}
  end

  defp send_pulses(
         {modules, states},
         [{target, signal, origin} | target_queue],
         i,
         observations
       ) do
    target_info = Map.get(modules, target)

    observations =
      if signal && Map.get(observations, origin, false) == nil do
        Map.put(observations, origin, i)
      else
        observations
      end

    if target_info == nil do
      send_pulses({modules, states}, target_queue, i, observations)
    else
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

      send_pulses({modules, states}, target_queue ++ new_targets, i, observations)
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

    [parent] = Map.get(target_relations, "rx")
    to_observe = Map.get(target_relations, parent)

    {modules, states, to_observe}
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
