defmodule Blockchain.Block do
  @moduledoc """
  A block
  """
  defstruct ~w(headers)a

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

  def mine(%__MODULE__{} = _lastBlock) do
  end
end
