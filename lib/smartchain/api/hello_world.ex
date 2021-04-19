defmodule Smartchain.Api.HelloWorld do
  use Plug.Router
  use Plug.ErrorHandler

  require Logger

  alias Smartchain.Blockchain.Agent
  alias Smartchain.Blockchain.Block
  alias Smartchain.Blockchain.Blockchain

  plug(:match)
  plug(:dispatch)

  get "/blockchain" do
    %{chain: chain} = _blockchain = Agent.get()

    send_resp(conn, 200, Jason.encode!(chain))
  end

  get "/blockchain/mine" do
    %{chain: chain} = blockchain = Agent.get()
    last_block = List.first(chain)
    block = Block.mine(last_block, "me")
    blockchain = Blockchain.add_block(blockchain, block)
    Agent.update(blockchain)

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
