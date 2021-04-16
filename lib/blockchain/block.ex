defmodule Blockchain.Block do
  @moduledoc """
  A block
  """
  defstruct ~w(headers)a

  alias Helpers.Util

  @hash_length 64
  @max_hash_value "f" |> String.duplicate(@hash_length) |> String.to_integer(16)
  @max_nonce_value :math.pow(2, 64)

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

  def calculate_target_block_hash(%__MODULE__{} = last_block) do
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
    |> IO.inspect(label: "Target hash")
  end

  def mine(%__MODULE__{} = last_block, beneficiary) do
    with target_hash <- calculate_target_block_hash(last_block),
         new_headers <- build_headers(last_block, beneficiary),
         {nonce, try_hash} <- calculate_nonce_and_try_hash(new_headers) do
      if String.to_integer(try_hash, 16) < String.to_integer(target_hash, 16) do
        # Found valid block
        %__MODULE__{
          headers: Map.put(new_headers, :nonce, nonce)
        }
      else
        # Try again until we find it
        mine(last_block, beneficiary)
      end
    end
  end

  defp build_headers(last_block, beneficiary) do
    %{
      parent_hash: Util.keccak_hash(last_block.headers),
      beneficiary: beneficiary,
      difficulty: last_block.headers.difficulty + 1,
      number: last_block.headers.number + 1,
      timestamp: System.os_time(:millisecond)
    }
  end

  defp calculate_nonce_and_try_hash(new_headers) do
    header_hash_integer_value =
      new_headers
      |> Util.keccak_hash()
      |> String.to_integer(16)

    nonce =
      (:rand.uniform() * @max_nonce_value)
      |> Float.floor()
      |> Kernel.trunc()

    try_hash =
      (header_hash_integer_value + nonce)
      |> Integer.to_string(16)
      |> Util.keccak_hash()
      |> IO.inspect(label: "Attempted hash")

    {nonce, try_hash}
  end
end

IO.inspect(Blockchain.Block.mine(Blockchain.Block.genesis(), "me"))
