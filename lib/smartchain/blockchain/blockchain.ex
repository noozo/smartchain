defmodule Smartchain.Blockchain.Blockchain do
  @moduledoc """
  The blockchain itself
  """
  defstruct ~w(chain)a

  require Logger

  alias Smartchain.Blockchain.Agent, as: BlockChainAgent
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

  def replace_blockchain(%{chain: chain} = blockchain) do
    chain
    |> Enum.reverse()
    |> Enum.reduce({true, List.first(chain)}, fn block, {all_valid?, last_block} ->
      valid? = {:ok, :valid} == Block.validate_block(last_block, block)
      {all_valid? and valid?, block}
    end)
    |> case do
      {true, _last_block} -> Logger.info("All blocks valid, replacing chain...")
      BlockChainAgent.update(blockchain)
      {false, _last_block} -> Logger.warn("Invalid blocks found, keeping existing chain")
    end
  end

  def replace_blockchain_from_peer([]),
    do: Logger.info("No one else is connected, using my own blockchain.")

  def replace_blockchain_from_peer([node]), do: replace_blockchain_from_peer(node)
  def replace_blockchain_from_peer([node | _rest]), do: replace_blockchain_from_peer(node)

  def replace_blockchain_from_peer(node) do
    # At least one peer is connected, let's ask someone for its blockchain
    peer_blockchain = Agent.get({BlockChainAgent, node}, &Map.get(&1, :blockchain))
    replace_blockchain(peer_blockchain)
  end
end
