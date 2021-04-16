defmodule Helpers.Util do
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
end
