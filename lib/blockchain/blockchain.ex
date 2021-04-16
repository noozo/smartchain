defmodule Blockchain.Blockchain do
  @moduledoc """
  The blockchain itself
  """
  defstruct ~w(chain)a

  alias Blockchain.Block

  def new do
    %__MODULE__{
      chain: [Block.genesis()]
    }
  end
end
