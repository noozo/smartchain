defmodule Blockchain.Blockchain do
  @moduledoc """
  The blockchain itself
  """
  defstruct ~w(chain)a

  alias Blockchain.Block

  def new do
    %__MODULE__{
      chain: [Block.genesis()]
    }
  end

  def add_block(%{chain: chain} = blockchain, block) do
    last_block = List.first(chain)

    case Block.validate_block(last_block, block) do
      {:ok, :valid} -> Map.put(blockchain, :chain, [block | chain])
      _ -> blockchain
    end
  end
end
