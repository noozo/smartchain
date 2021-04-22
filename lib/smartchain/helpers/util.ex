defmodule Smartchain.Helpers.Util do
  @moduledoc """
  Util functions
  """

  @doc """
  Calculates keccak 256 hash of input map

  Examples:

      iex> Util.keccak_hash(%{foo: :bar})
      "0C67568EF95AFD46944FAE1ABC2B7D6227AA410E6250A554CBAAB0FB17074205"
      iex> hash1 = Util.keccak_hash(%{foo: :bar, bar: :foo})
      iex> hash2 = Util.keccak_hash(%{bar: :foo, foo: :bar})
      iex> hash1 == hash2
      true
      iex> hash3 = Util.keccak_hash(%{bar: :foo, foo: :bar2})
      iex> hash1 == hash3
      false
      iex> hash2 == hash3
      false
  """
  def keccak_hash(data) do
    # NOTE: Replace ex_sha3 with native version for performance
    data
    |> Jason.encode!()
    |> ExSha3.keccak_256()
    |> Base.encode16()
  end

  # def cenas do
  #   Curvy.generate_key()
  #   iex> sig = Curvy.sign("hello", key)
  #   <<sig::binary-size(71)>>

  #   iex> sig = Curvy.sign("hello", compact: true)
  #   <<sig::binary-size(65)>>

  #   iex> sig = Curvy.sign("hello", compact: true, encoding: :base64)
  #   "IEnXUDXZ3aghwXaq1zu9ax2zJj7N+O4gGREmWBmrldwrIb9B7QuicjwPrrv3ocPpxYO7uCxcw+DR/FcHR9b/YjM="

  #   iex> sig = Curvy.verify(sig, "hello", key)
  #   true
  # end
end
