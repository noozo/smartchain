# config/config.exs
use Mix.Config

if Mix.env() == :dev do
  config :mix_test_watch,
    tasks: [
      "format",
      "test --color",
      "credo --strict"
    ]
end

if Mix.env() == :test do
  config :logger, level: :warn
end
