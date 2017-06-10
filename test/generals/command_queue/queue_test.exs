defmodule Generals.CommandQueue.QueueTest do
  use ExUnit.Case, async: true

  alias Generals.CommandQueue.Command
  alias Generals.CommandQueue.Queue

  setup do
    {:ok, queue: %Queue{}}
  end

  test "initialization provides empty turn mappings", %{queue: queue} do
    assert Queue.for_turn(queue, 1) == []
    assert Queue.for_turn(queue, 10) == []
  end

  describe "add/3" do
    test "commands can be added for a turn", %{queue: queue} do
      command = %Command{player: 1}
      command2 = %Command{player: 2}
      assert queue
        |> Queue.add(1, command)
        |> Queue.add(1, command2)
        |> Queue.for_turn(1) == [command, command2]
    end

    test "multiple commands for a player are placed in subsequent turns", %{queue: queue} do
      command = %Command{player: 1, type: :a}
      command2 = %Command{player: 1, type: :b}
      command3 = %Command{player: 1, type: :c}
      command4 = %Command{player: 2, type: :c}

      queue = queue
        |> Queue.add(1, command)
        |> Queue.add(1, command2)
        |> Queue.add(1, command3)
        |> Queue.add(1, command4)
      assert Queue.for_turn(queue, 1) == [command, command4]
      assert Queue.for_turn(queue, 2) == [command2]
      assert Queue.for_turn(queue, 3) == [command3]
    end
  end

  describe "clear_for_player/3" do
    test "can be called with an empty queue", %{queue: queue} do
      assert Queue.clear_for_player(queue, player: 1, from_turn: 2) == queue
    end

    test "all moves from the turn and on are removed", %{queue: queue} do
      command = %Command{player: 1}
      command2 = %Command{player: 2}
      queue = queue
        |> Queue.add(1, command)
        |> Queue.add(1, command)
        |> Queue.add(1, command)
        |> Queue.add(1, command2)
        |> Queue.add(1, command2)
      queue = Queue.clear_for_player(queue, player: 1, from_turn: 2)
      assert Queue.for_turn(queue, 1) == [command, command2]
      assert Queue.for_turn(queue, 2) == [command2]
      assert Queue.for_turn(queue, 3) == []
    end
  end
end
