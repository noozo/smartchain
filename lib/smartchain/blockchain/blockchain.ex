defmodule Smartchain.Blockchain.Blockchain do
  @moduledoc """
  The blockchain itself
  """
  defstruct ~w(chain)a

  require Logger

  alias Smartchain.Blockchain.Block

  def new do
    %__MODULE__{
      chain: [Block.genesis()]
    }
  end

  def last_block(%{chain: chain} = _blockchain), do: List.first(chain)

  def add_block(%{chain: chain} = blockchain, block) do
    last_block = List.first(chain)

    case Block.validate_block(last_block, block) do
      {:ok, :valid} ->
        Logger.info("New block accepted")
        Map.put(blockchain, :chain, [block | chain])
      _ ->
        Logger.info("New block rejected")
        blockchain
    end
  end
end
