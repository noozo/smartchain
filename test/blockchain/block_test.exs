defmodule Blockchain.BlockTest do
  use ExUnit.Case

  alias Blockchain.Block
  alias Blockchain.TargetBlockHashCalculator
  alias Helpers.Util

  doctest Block, import: true

  import Mox
  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  setup(data) do
    # If no expectations are defined, use the real deal
    Mox.stub_with(
      Blockchain.TargetBlockHashCalculator.MockImpl,
      Blockchain.TargetBlockHashCalculator.Impl
    )

    data
  end

  describe "mine/2" do
    setup do
      last_block = Block.genesis()

      %{
        last_block: last_block,
        mined_block: Block.mine(last_block, "me")
      }
    end

    test "mines a block", %{mined_block: mined_block} do
      assert %Block{} = mined_block
    end

    test "it mines a block that meets the proof of work requirement", %{
      mined_block: %{headers: %{nonce: nonce} = headers} = _mined_block,
      last_block: last_block
    } do
      target_hash_value =
        last_block
        |> TargetBlockHashCalculator.calculate_target_block_hash()
        |> String.to_integer(16)

      try_hash_value =
        headers
        |> Map.delete(:nonce)
        |> Util.keccak_hash()
        |> String.to_integer(16)
        # Value representation of the headers
        |> Kernel.+(nonce)
        # Added the nonce
        |> Integer.to_string(16)
        # Made into a 16 base string
        |> Util.keccak_hash()
        |> String.to_integer(16)

      assert try_hash_value < target_hash_value
    end
  end

  describe "adjust_difficulty/2" do
    test "it keeps the difficulty above 0" do
      new_difficulty =
        Block.adjust_difficulty(%Block{headers: %{difficulty: 0}}, System.os_time(:millisecond))

      assert new_difficulty == 1
    end

    test "increases the difficulty for a quickly mined block" do
      new_difficulty =
        Block.adjust_difficulty(%Block{headers: %{difficulty: 5, timestamp: 1000}}, 3000)

      assert new_difficulty == 6
    end

    test "decreases the difficulty for a slowly mined block" do
      new_difficulty =
        Block.adjust_difficulty(%Block{headers: %{difficulty: 5, timestamp: 1000}}, 20_000)

      assert new_difficulty == 4
    end
  end

  describe "validate_block/2" do
    setup do
      last_block = Block.genesis()

      %{
        last_block: last_block,
        block: Block.mine(last_block, "me")
      }
    end

    test "the genesis block is always valid", %{last_block: genesis} do
      assert {:ok, :valid} == Block.validate_block(nil, genesis)
    end

    test "validates if block is valid", %{last_block: last_block, block: block} do
      assert {:ok, :valid} == Block.validate_block(last_block, block)
    end

    test "does not validate if the parent_hash is invalid", %{
      last_block: last_block,
      block: block
    } do
      block = put_in(block, [:headers, :parent_hash], "foobar")
      assert {:error, :invalid_parent_hash} == Block.validate_block(last_block, block)
    end

    test "does not validate if the number is not sequential", %{
      last_block: last_block,
      block: block
    } do
      block = put_in(block, [:headers, :number], 1000)
      assert {:error, :invalid_number} == Block.validate_block(last_block, block)
    end

    test "does not validate if the difficulty changed by more than 1", %{
      last_block: last_block,
      block: block
    } do
      block = put_in(block, [:headers, :difficulty], 5)
      assert {:error, :invalid_difficulty} == Block.validate_block(last_block, block)
    end

    test "does not validate if proof of work cannot be validated", %{
      last_block: last_block,
      block: block
    } do
      # Fake the target block hash calculation to a really low number, so that
      # the new block cannot have a lower value and fails the proof of work
      expect(
        Blockchain.TargetBlockHashCalculator.MockImpl,
        :calculate_target_block_hash,
        fn _last_block ->
          String.duplicate("0", 64)
        end
      )

      assert {:error, :proof_of_work_validation_failed} == Block.validate_block(last_block, block)
    end
  end
end
