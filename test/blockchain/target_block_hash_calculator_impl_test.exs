defmodule Blockchain.TargetBlockHashCalculatorImplTest do
  use ExUnit.Case

  alias Blockchain.Block
  alias Blockchain.TargetBlockHashCalculator

  defp block(difficulty, base \\ Block.genesis()) do
    headers = Map.put(base.headers, :difficulty, difficulty)
    Map.put(base, :headers, headers)
  end

  describe "calculate_target_block_hash/1" do
    test "Calculates max hash when difficulty is 1" do
      result = TargetBlockHashCalculator.Impl.calculate_target_block_hash(block(1))
      assert result == String.duplicate("F", 64)
    end

    test "Calculates an hash left padded with zeros when hash is smaller than 64" do
      result = TargetBlockHashCalculator.Impl.calculate_target_block_hash(block(500))
      assert String.length(result) == 64
      assert result == "0083126E978D4FDF3B645A1CAC083126E978D4FDF3B645A1CAC083126E978D4F"
    end
  end
end
