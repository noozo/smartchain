defmodule Blockchain.TargetBlockHashCalculator do
  @moduledoc """
  Calculates a target hash for a block based on some difficulty
  """
  alias Blockchain.Block

  @callback calculate_target_block_hash(Block.t()) :: String.t()

  def calculate_target_block_hash(last_block),
    do: calculator().calculate_target_block_hash(last_block)

  def calculator do
    Application.get_env(
      :smartchain,
      :target_block_hash_calculator,
      Blockchain.TargetBlockHashCalculator.Impl
    )
  end
end

defmodule Blockchain.TargetBlockHashCalculator.Impl do
  @moduledoc """
  Implementation
  """
  @behaviour Blockchain.TargetBlockHashCalculator

  @hash_length 64
  @max_hash_value "f" |> String.duplicate(@hash_length) |> String.to_integer(16)

  @impl true
  def calculate_target_block_hash(last_block) do
    value = Integer.to_string(div(@max_hash_value, last_block.headers.difficulty), 16)

    # Prevent hash overflow (should not happen in elixir)
    value =
      if String.length(value) > @hash_length do
        String.duplicate("f", @hash_length)
      else
        value
      end

    # Prevent hashes with less than 64 chars by prefixing with
    # the necessary number of zero characters
    "#{String.duplicate("0", 64 - String.length(value))}#{value}"
  end
end
