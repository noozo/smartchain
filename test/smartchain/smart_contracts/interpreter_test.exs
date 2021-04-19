defmodule Smartchain.SmartContracts.InterpreterTest do
  use ExUnit.Case
  alias Smartchain.SmartContracts.Interpreter
  doctest Interpreter, import: true

  describe "push" do
    test "valid" do
      {:ok, pid} = Interpreter.start_link([:push, 2, :stop])
      assert 2 == Interpreter.run_code(pid)
    end

    test "invalid" do
      {:ok, pid} = Interpreter.start_link([:push, 0, :push])

      assert_raise RuntimeError, fn ->
        Interpreter.run_code(pid)
      end
    end
  end

  test "add" do
    {:ok, pid} = Interpreter.start_link([:push, 2, :push, 3, :add, :stop])
    assert 5 == Interpreter.run_code(pid)
  end

  test "sub" do
    {:ok, pid} = Interpreter.start_link([:push, 2, :push, 3, :sub, :stop])
    assert 1 == Interpreter.run_code(pid)
  end

  test "mul" do
    {:ok, pid} = Interpreter.start_link([:push, 2, :push, 3, :mul, :stop])
    assert 6 == Interpreter.run_code(pid)
  end

  test "div" do
    {:ok, pid} = Interpreter.start_link([:push, 2, :push, 3, :div, :stop])
    assert 1.5 == Interpreter.run_code(pid)
  end

  test "lt" do
    {:ok, pid} = Interpreter.start_link([:push, 2, :push, 3, :lt, :stop])
    assert 0 == Interpreter.run_code(pid)
  end

  test "gt" do
    {:ok, pid} = Interpreter.start_link([:push, 2, :push, 3, :gt, :stop])
    assert 1 == Interpreter.run_code(pid)
  end

  test "eq" do
    {:ok, pid} = Interpreter.start_link([:push, 2, :push, 3, :eq, :stop])
    assert 0 == Interpreter.run_code(pid)
  end

  test "and" do
    {:ok, pid} = Interpreter.start_link([:push, 1, :push, 0, :and, :stop])
    assert 0 == Interpreter.run_code(pid)
  end

  test "or" do
    {:ok, pid} = Interpreter.start_link([:push, 1, :push, 0, :or, :stop])
    assert 1 == Interpreter.run_code(pid)
  end

  describe "jump" do
    test "valid" do
      {:ok, pid} =
        Interpreter.start_link([:push, 6, :jump, :push, 0, :jump, :push, "jump success", :stop])

      assert "jump success" == Interpreter.run_code(pid)
    end

    test "invalid - out of bounds" do
      {:ok, pid} =
        Interpreter.start_link([:push, 99, :jump, :push, 0, :jump, :push, "jump success", :stop])

      assert_raise RuntimeError, fn ->
        Interpreter.run_code(pid)
      end
    end

    test "invalid - infinite loop" do
      {:ok, pid} = Interpreter.start_link([:push, 0, :jump, :stop])

      assert_raise RuntimeError, fn ->
        Interpreter.run_code(pid)
      end
    end
  end

  test "jumpi" do
    {:ok, pid} =
      Interpreter.start_link([
        :push,
        8,
        :push,
        1,
        :jumpi,
        :push,
        0,
        :jump,
        :push,
        "conditional jump success",
        :stop
      ])

    assert "conditional jump success" == Interpreter.run_code(pid)
  end
end
