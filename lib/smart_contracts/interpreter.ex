defmodule SmartContracts.Interpreter do
  @moduledoc """
  Smartchain interpreter and agent
  """
  use Agent

  alias Helpers.Stack

  @loc_limit 10_000

  def start_link(code) do
    Agent.start_link(fn ->
      %{
        code: code_to_map(code),
        loc: Enum.count(code),
        stack: Stack.new(),
        program_counter: 0,
        execution_count: 0
      }
    end)
  end

  defp code_to_map(code) do
    code
    |> Enum.with_index()
    |> Enum.map(fn {code, index} -> {index, code} end)
    |> Map.new()
  end

  defp increase_program_counter(pid) do
    current_program_counter = Agent.get(pid, &Map.get(&1, :program_counter))
    :ok = Agent.update(pid, &Map.put(&1, :program_counter, current_program_counter + 1))
    current_program_counter + 1
  end

  defp set_program_counter(pid, value) do
    :ok = Agent.update(pid, &Map.put(&1, :program_counter, value))
    value
  end

  defp push_stack(pid, stack, value) do
    stack = Stack.push(stack, value)
    :ok = Agent.update(pid, &Map.put(&1, :stack, stack))
    stack
  end

  defp pop_stack(pid, stack) do
    {value, stack} = Stack.pop(stack)
    :ok = Agent.update(pid, &Map.put(&1, :stack, stack))
    {value, stack}
  end

  def run_code(pid) do
    %{
      code: code,
      execution_count: execution_count,
      program_counter: program_counter
    } = state = Agent.get(pid, fn state -> state end)

    state = Map.put(state, :execution_count, execution_count + 1)
    :ok = Agent.update(pid, fn _old_state -> state end)

    if execution_count > @loc_limit do
      raise "Execution count exceeded #{@loc_limit} loc. Do you have an infinite loop?"
    end

    op = code[program_counter]

    case execute_operation(pid, state, op) do
      {:finished, result} ->
        result

      _ ->
        increase_program_counter(pid)
        run_code(pid)
    end
  end

  defp math2(pid, stack, func) do
    {value1, stack} = pop_stack(pid, stack)
    {value2, stack} = pop_stack(pid, stack)
    push_stack(pid, stack, func.(value1, value2))
  end

  defp jump(pid, stack) do
    {destination, _stack} = pop_stack(pid, stack)
    max_jump_loc = Agent.get(pid, &Map.get(&1, :loc)) - 1

    if destination < 0 or destination > max_jump_loc do
      raise "Jump destination invalid: #{destination}"
    end

    # Decreasing one because we will increase in run_code every time
    set_program_counter(pid, destination - 1)
  end

  defp execute_operation(pid, %{stack: stack}, :stop) do
    {result, _stack} = pop_stack(pid, stack)
    {:finished, result}
  end

  defp execute_operation(pid, %{code: code, loc: loc, stack: stack}, :push) do
    program_counter = increase_program_counter(pid)

    if program_counter >= loc do
      raise "Push instruction cannot be last"
    end

    value = code[program_counter]
    push_stack(pid, stack, value)
  end

  defp execute_operation(pid, %{stack: stack}, :add), do: math2(pid, stack, &(&1 + &2))

  defp execute_operation(pid, %{stack: stack}, :sub), do: math2(pid, stack, &(&1 - &2))

  defp execute_operation(pid, %{stack: stack}, :mul), do: math2(pid, stack, &(&1 * &2))

  defp execute_operation(pid, %{stack: stack}, :div), do: math2(pid, stack, &(&1 / &2))

  defp execute_operation(pid, %{stack: stack}, :lt),
    do: math2(pid, stack, &if(&1 < &2, do: 1, else: 0))

  defp execute_operation(pid, %{stack: stack}, :gt),
    do: math2(pid, stack, &if(&1 > &2, do: 1, else: 0))

  defp execute_operation(pid, %{stack: stack}, :eq),
    do: math2(pid, stack, &if(&1 == &2, do: 1, else: 0))

  defp execute_operation(pid, %{stack: stack}, :and),
    do: math2(pid, stack, &if(&1 == 1 and &2 == 1, do: 1, else: 0))

  defp execute_operation(pid, %{stack: stack}, :or),
    do: math2(pid, stack, &if(&1 == 1 or &2 == 1, do: 1, else: 0))

  defp execute_operation(pid, %{stack: stack}, :jump), do: jump(pid, stack)

  defp execute_operation(pid, %{stack: stack}, :jumpi) do
    {condition, stack} = pop_stack(pid, stack)

    if condition == 1 do
      jump(pid, stack)
    end
  end
end
