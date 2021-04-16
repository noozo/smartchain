defmodule Blockchain.Block do
  @moduledoc """
  A block
  """
  @derive Jason.Encoder

  @behaviour Access
  defdelegate get(v, key, default), to: Map
  defdelegate fetch(v, key), to: Map
  defdelegate get_and_update(v, key, func), to: Map
  defdelegate pop(v, key), to: Map

  defstruct ~w(headers)a

  require Logger

  alias Blockchain.TargetBlockHashCalculator
  alias Helpers.Util

  @max_nonce_value :math.pow(2, 64)
  @milliseconds 1
  @seconds 1000 * @milliseconds
  # Mine a block every 13 seconds
  @mine_rate 13 * @seconds

  @genesis %{
    headers: %{
      parent_hash: "--genesis-parent-hash--",
      beneficiary: "--genesis-beneficiary-hash--",
      difficulty: 1,
      number: 0,
      timestamp: "--genesis-timestamp--",
      nonce: 0
    }
  }

  def genesis, do: struct!(__MODULE__, @genesis)

  def validate_block(last_block, block) do
    cond do
      # Genesis block is always valid
      Util.keccak_hash(block) == Util.keccak_hash(genesis()) ->
        {:ok, :valid}

      # Parent hash must be hash of the previous block
      Util.keccak_hash(last_block.headers) != block.headers.parent_hash ->
        {:error, :invalid_parent_hash}

      # The block numbers must be sequential
      block.headers.number != last_block.headers.number + 1 ->
        {:error, :invalid_number}

      # Difficulty cannot change by more than 1 between blocks
      abs(last_block.headers.difficulty - block.headers.difficulty) > 1 ->
        {:error, :invalid_difficulty}

      # Proof of work validation
      invalid_proof_of_work?(last_block, block) ->
        {:error, :proof_of_work_validation_failed}

      true ->
        {:ok, :valid}
    end
  end

  def mine(%__MODULE__{} = last_block, beneficiary) do
    with target_hash <- TargetBlockHashCalculator.calculate_target_block_hash(last_block),
         new_headers <- build_headers(last_block, beneficiary),
         {nonce, try_hash} <- calculate_nonce_and_try_hash(new_headers) do
      if String.to_integer(try_hash, 16) < String.to_integer(target_hash, 16) do
        # Found valid block
        Logger.debug("Block found. Current difficulty: #{new_headers.difficulty}")

        %__MODULE__{
          headers: Map.put(new_headers, :nonce, nonce)
        }
      else
        # Try again until we find it
        mine(last_block, beneficiary)
      end
    end
  end

  # Adjust difficulty down, to a minimum of 1
  def adjust_difficulty(
        %{headers: %{difficulty: difficulty, timestamp: last_block_timestamp}} = _last_block,
        timestamp
      )
      when timestamp - last_block_timestamp > @mine_rate do
    new_difficulty = difficulty - 1
    if new_difficulty < 1, do: 1, else: new_difficulty
  end

  # Adjust difficulty up otherwise
  def adjust_difficulty(%{headers: %{difficulty: difficulty}} = _last_block, _timestamp),
    do: difficulty + 1

  defp build_headers(last_block, beneficiary) do
    timestamp = System.os_time(:millisecond)

    %{
      parent_hash: Util.keccak_hash(last_block.headers),
      beneficiary: beneficiary,
      difficulty: adjust_difficulty(last_block, timestamp),
      number: last_block.headers.number + 1,
      timestamp: timestamp
    }
  end

  defp calculate_nonce_and_try_hash(new_headers) do
    nonce =
      (:rand.uniform() * @max_nonce_value)
      |> Float.floor()
      |> Kernel.trunc()

    try_hash = calculate_try_hash(new_headers, nonce)

    {nonce, try_hash}
  end

  defp invalid_proof_of_work?(last_block, %{headers: %{nonce: nonce} = headers} = _block) do
    target_hash_value =
      last_block
      |> TargetBlockHashCalculator.calculate_target_block_hash()
      |> String.to_integer(16)

    try_hash_value =
      headers
      |> calculate_try_hash(nonce)
      |> String.to_integer(16)

    try_hash_value >= target_hash_value
  end

  defp calculate_try_hash(headers, nonce) do
    headers
    |> Map.delete(:nonce)
    |> Util.keccak_hash()
    |> String.to_integer(16)
    # Value representation of the headers
    |> Kernel.+(nonce)
    # Added the nonce
    |> Integer.to_string(16)
    # Made into a 16 base string
    |> Util.keccak_hash()
  end
end
