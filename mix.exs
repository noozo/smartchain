defmodule Interpreter.MixProject do
  use Mix.Project

  def project do
    [
      app: :smartchain,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      preferred_cli_env: ["test.watch": :test]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_sha3, "~> 0.1.0"},
      # Testing and dev
      {:mix_test_watch, "~> 1.0.2", only: [:dev, :test], runtime: false},
      {:ex_unit_notifier, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.5.0-rc.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.7", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      sobelow: [],
      "test.watch": [
        "format",
        "test --color",
        "credo --strict"
      ]
    ]
  end
end
