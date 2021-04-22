defmodule Smartchain.Account do
  @moduledoc """
  Accounts
  """
  defstruct ~w(key_pair address balance)a

  @starting_balance 1000

  alias Smartchain.Helpers.Util

  def new do
    key_pair = Curvy.generate_key()

    %__MODULE__{
      key_pair: key_pair,
      address: key_pair |> Curvy.Key.to_pubkey() |> Base.hex_encode32(),
      balance: @starting_balance
    }
  end

  def sign(account, data), do: data |> Util.keccak_hash() |> Curvy.sign(account.key_pair.privkey)

  def verify_signature(public_key, data, signature) do
    # Creating a new public key for verification because the public_key/address
    # will come in as an hex_encoded string, and we need to decode it first
    # See the sign/2 function for reference
    verification_public_key = public_key |> Base.hex_decode32!() |> Curvy.Key.from_pubkey()
    Curvy.verify(signature, Util.keccak_hash(data), verification_public_key)
  end
end
