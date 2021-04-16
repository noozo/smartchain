defmodule Stack do
  @moduledoc """
  A simple stack

  Examples

      iex> stack = Stack.new()
      %Stack{elements: []}
      iex> Stack.pop(stack)
      ** (RuntimeError) Stack is empty!
      iex> stack = Stack.push(stack, 1)
      %Stack{elements: [1]}
      iex> stack = Stack.push(stack, 2)
      %Stack{elements: [2, 1]}
      iex> Stack.depth(stack)
      2
      iex> {2, _stack} = Stack.pop(stack)
      {2, %Stack{elements: [1]}}
  """
  defstruct elements: []

  def new, do: %Stack{}

  def push(stack, element) do
    %Stack{stack | elements: [element | stack.elements]}
  end

  def pop(%Stack{elements: []}), do: raise("Stack is empty!")

  def pop(%Stack{elements: [top | rest]}) do
    {top, %Stack{elements: rest}}
  end

  def depth(%Stack{elements: elements}), do: length(elements)
end
