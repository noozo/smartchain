defmodule Smartchain.Api.HelloWorld do
  use Plug.Router
  use Plug.ErrorHandler

  require Logger

  alias Smartchain.Blockchain.Agent
  alias Smartchain.Blockchain.Block
  alias Smartchain.Blockchain.Blockchain
  alias Smartchain.Blockchain.PubSub

  plug(:match)
  plug(:dispatch)

  get "/blockchain" do
    %{chain: chain} = _blockchain = Agent.get()

    send_resp(conn, 200, Jason.encode!(chain))
  end

  get "/blockchain/mine" do

    block = Agent.get()
    |> Blockchain.last_block()
    |> Block.mine("me")

    Agent.get()
    |> Blockchain.add_block(block)
    |> Agent.update()

    PubSub.broadcast_block(block)

    send_resp(conn, 200, Jason.encode!(block))
  end

  # forward "/users", to: UsersRouter

  match _ do
    send_resp(conn, 404, "Not found.")
  end

  def handle_errors(conn, %{kind: _kind, reason: reason, stack: _stack}) do
    send_resp(conn, conn.status, "Something went wrong: #{reason.message}.")
  end
end
