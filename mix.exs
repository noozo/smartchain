defmodule Interpreter.MixProject do
  use Mix.Project

  def project do
    [
      app: :smartchain,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Smartchain.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:curvy, "~> 0.1"},
      {:phoenix_pubsub, "~> 2.0"},
      {:libcluster, "~> 3.2"},
      {:plug_cowboy, "~> 2.0"},
      {:ex_sha3, "~> 0.1.0"},
      # Testing and dev
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:ex_unit_notifier, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.5.0-rc.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.7", only: [:dev, :test], runtime: false},
      {:mox, "~> 1.0.0", only: :test}
    ]
  end

  defp aliases do
    [
      sobelow: []
    ]
  end
end
