defmodule Smartchain.Blockchain.Agent do
  @moduledoc """
  Smartchain agent. keeps the blockchain state.
  """
  use Agent

  require Logger

  alias Smartchain.Blockchain.Blockchain

  def start_link([]) do
    Logger.info("Starting blockchain agent...")

    Agent.start_link(
      fn ->
        %{
          blockchain: Blockchain.new()
        }
      end,
      name: __MODULE__
    )
  end

  def get do
    Agent.get(__MODULE__, &Map.get(&1, :blockchain))
  end

  def update(blockchain) do
    :ok = Agent.update(__MODULE__, &Map.put(&1, :blockchain, blockchain))
    blockchain
  end
end
