defmodule Smartchain.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {Plug.Cowboy, scheme: :http, plug: Smartchain.Api.HelloWorld, options: [port: 4001]},
      {Smartchain.Blockchain.Agent, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Smartchain.Api.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
