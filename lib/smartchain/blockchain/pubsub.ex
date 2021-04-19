defmodule Smartchain.Blockchain.Pubsub do
  @moduledoc """
  PubSub
  """
  use GenServer

  require Logger

  @me __MODULE__

  def start_link([]) do
    Logger.info("Starting PubSub GenServer...")
    {:ok, _pid} = result = GenServer.start_link(__MODULE__, [:pubsub], name: @me)
    result
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def subscribe, do: GenServer.call(@me, :subscribe)
  def broadcast, do: GenServer.call(@me, :broadcast)

  def handle_call(:subscribe, _from, state) do
    result = Phoenix.PubSub.subscribe(Smartchain.PubSub, "block")
    {:reply, result, state}
  end

  def handle_call(:broadcast, _from, state) do
    result = Phoenix.PubSub.broadcast(Smartchain.PubSub, "block", :hello_world)
    {:reply, result, state}
  end

  def handle_info(:hello_world, state) do
    IO.inspect("Got hello world")
    {:noreply, state}
  end
end
