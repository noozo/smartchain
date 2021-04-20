defmodule Smartchain.Blockchain.PubSub do
  @moduledoc """
  PubSub
  """
  use GenServer

  require Logger

  alias Smartchain.Blockchain.Agent
  alias Smartchain.Blockchain.Block
  alias Smartchain.Blockchain.Blockchain

  @me __MODULE__

  @channels ~w(block test)

  def start_link([]) do
    Logger.info("Starting PubSub GenServer...")
    {:ok, _pid} = result = GenServer.start_link(__MODULE__, %{}, name: @me)
    result
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def subscribe, do: GenServer.call(@me, :subscribe)
  def broadcast(channel, message), do: GenServer.call(@me, {:broadcast, channel, message})
  def broadcast_block(block), do: broadcast("block", block)

  def handle_call(:subscribe, _from, state) do
    Enum.each(@channels, fn channel ->
      :ok = Phoenix.PubSub.subscribe(Smartchain.PubSub, channel)
    end)

    {:reply, :ok, state}
  end

  def handle_call({:broadcast, channel, message}, _from, state) do
    result = Phoenix.PubSub.broadcast(Smartchain.PubSub, channel, message)
    {:reply, result, state}
  end

  def handle_info(%Block{} = block, state) do
    Logger.debug("Got a block: #{inspect(block)}")

    Agent.get()
    |> Blockchain.add_block(block)
    |> Agent.update()

    {:noreply, state}
  end

  def handle_info(other_message, state) do
    Logger.warn("Unhandled message received: #{inspect(other_message)}")
    {:noreply, state}
  end
end
