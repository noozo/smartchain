defmodule Smartchain.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Smartchain.Blockchain

  def start(_type, _args) do
    api_port = String.to_integer(System.fetch_env!("API_PORT"))

    # List all child processes to be supervised
    children = [
      {Cluster.Supervisor,
       [Application.get_env(:libcluster, :topologies), [name: Smartchain.ClusterSupervisor]]},
      {Plug.Cowboy, scheme: :http, plug: Smartchain.Api.Router, options: [port: api_port]},
      {Smartchain.Blockchain.Agent, []},
      {Smartchain.Blockchain.PubSub, []},
      {Phoenix.PubSub, name: Smartchain.PubSub}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Smartchain.Api.Supervisor]
    result = Supervisor.start_link(children, opts)

    # Request initial blockchain from a peer, if one is available
    Blockchain.replace_blockchain_from_peer(Node.list())

    result
  end
end
