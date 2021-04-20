require Logger

alias Smartchain.Blockchain.PubSub
alias Smartchain.Blockchain.Agent

Logger.info("Hello #{Node.self()}")
PubSub.subscribe()
