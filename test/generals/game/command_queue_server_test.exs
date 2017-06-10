defmodule Generals.Game.CommandQueueServerTest do
  use ExUnit.Case, async: true

  alias Generals.CommandQueue.Command
  alias Generals.Game.CommandQueueServer

  describe "commands_for_turn/2" do
    test "initially is empty" do
      {:ok, pid} = CommandQueueServer.start_link
      assert CommandQueueServer.commands_for_turn(pid, 1) == []
    end
  end

  describe "add_command/2" do
    test "the command is added for the turn" do
      {:ok, pid} = CommandQueueServer.start_link
      assert CommandQueueServer.add_command(pid, 1, %Command{player: 1}) == :ok
      assert CommandQueueServer.commands_for_turn(pid, 1) == [%Command{player: 1}]
      assert CommandQueueServer.commands_for_turn(pid, 2) == []
    end
  end

  describe "clear_player_commands/3" do
    test "commands after the given turn are cleared" do
      {:ok, pid} = CommandQueueServer.start_link
      assert CommandQueueServer.add_command(pid, 1, %Command{player: 1}) == :ok
      assert CommandQueueServer.add_command(pid, 1, %Command{player: 1}) == :ok
      assert CommandQueueServer.add_command(pid, 1, %Command{player: 2}) == :ok
      assert CommandQueueServer.commands_for_turn(pid, 1) == [%Command{player: 1}, %Command{player: 2}]
      assert CommandQueueServer.commands_for_turn(pid, 2) == [%Command{player: 1}]
      assert CommandQueueServer.commands_for_turn(pid, 3) == []
      CommandQueueServer.clear_player_commands(pid, 2, player: 1)
      assert CommandQueueServer.commands_for_turn(pid, 1) == [%Command{player: 1}, %Command{player: 2}]
      assert CommandQueueServer.commands_for_turn(pid, 2) == []
    end
  end
end
