defmodule Generals.Game.SupervisorTest do
  use ExUnit.Case, async: false # Not async due to coordination of processes

  alias Generals.Board
  alias Generals.Game

  test "the board is initialized with a provided board", context do
    board = Board.get_new(rows: 1, columns: 1)
    {:ok, sup} = Game.Supervisor.start_link(%{ game_id: context.test, board: board, user_ids: ["a"] })
    board_pid = Game.Supervisor.get_board_pid(sup)
    assert is_pid(board_pid)
    assert Game.BoardServer.get_board(board_pid) == board
  end

  test "the board is ticked correctly", context do
    board = Board.get_new(rows: 1, columns: 1)
      |> Board.replace_cell({0, 0}, %Board.Cell{ row: 0, column: 0, type: :general, owner: 1 })

    {:ok, sup} = Game.Supervisor.start_link(%{ game_id: context.test, board: board, timeout: 10, immediate_start: true, user_ids: ["a"] })
    board_pid = Game.Supervisor.get_board_pid(sup)

    assert Game.BoardServer.get_board(board_pid).cells == [[%Board.Cell{ column: 0, row: 0, owner: 1, population_count: 0, type: :general }]]
    Process.sleep(15)
    assert Game.BoardServer.get_board(board_pid).cells == [[%Board.Cell{ column: 0, row: 0, owner: 1, population_count: 1, type: :general }]]
  end

  @doc """
    Turn 1: Move 2 from 0,0 -> 0,1: 0,0=1, 0,1=2
    Turn 2: 0,0=1, 0,1=2
    Turn 3: Tick towns, 0,0=2, 1,0=1 0,1=2 1,1=0
  """
  test "commands for a turn are executed on a tick", context do
    board = Board.get_new(rows: 2, columns: 2)
      |> Board.replace_cell({0, 0}, %Board.Cell{ row: 0, column: 0, owner: 0, population_count: 3, type: :town })
      |> Board.replace_cell({1, 0}, %Board.Cell{ row: 1, column: 0, type: :town, owner: 0 })

    {:ok, sup} = Game.Supervisor.start_link(%{ game_id: context.test, board: board, timeout: 20, immediate_start: true, user_ids: ["a"] })
    assert Game.Supervisor.queue_move(sup, user: "a", from: {0,0}, to: {0,1}) == :ok
    assert Game.Supervisor.queue_move(sup, user: "a", from: {1,1}, to: {0,1}) == :ok

    board_pid = Game.Supervisor.get_board_pid(sup)
    assert Game.BoardServer.get_board(board_pid)
      |> Board.at({0,1})
      |> Map.take([:owner, :population_count]) == %{owner: nil, population_count: 0}

    tick_server = Game.Supervisor.get_tick_server_pid(sup)
    Process.sleep(25)
    refute Game.TickServer.ticking?(tick_server)

    %{board: board, turn: turn} = Game.BoardServer.get(board_pid)

    assert turn == 3
    assert board
      |> Board.at({0,0})
      |> Map.take([:owner, :population_count]) == %{owner: 0, population_count: 2}
    assert board
      |> Board.at({1,0})
      |> Map.take([:owner, :population_count]) == %{owner: 0, population_count: 1}
    assert board
      |> Board.at({0,1})
      |> Map.take([:owner, :population_count]) == %{owner: 0, population_count: 2}
    assert board
      |> Board.at({1,1})
      |> Map.take([:owner, :population_count]) == %{owner: nil, population_count: 0}
  end

  describe "player_has_access?/2" do
    test "returns false when the player isn't in the game", context do
      board = Board.get_new(rows: 1, columns: 1)
      {:ok, sup} = Game.Supervisor.start_link(%{ game_id: context.test, board: board, user_ids: ["a", "b"] })
      assert Game.Supervisor.player_has_access?(sup, "a") == true
      assert Game.Supervisor.player_has_access?(sup, "b") == true
      assert Game.Supervisor.player_has_access?(sup, "c") == false
    end
  end

  describe "queue_move/2" do
    test "the command queue has the given move added as a command", context do
      board = Board.get_new(rows: 2, columns: 2)
        |> Board.replace_cell({0, 0}, %Board.Cell{ row: 0, column: 0, owner: 0, population_count: 3 })

      {:ok, sup} = Game.Supervisor.start_link(%{ game_id: context.test, board: board, user_ids: ["a"] })
      assert Game.Supervisor.queue_move(sup, user: "a", from: {0,0}, to: {0,1}) == :ok

      queue_pid = Game.Supervisor.get_command_queue_pid(sup)
      assert length(Game.CommandQueueServer.commands_for_turn(queue_pid, 1)) == 1
    end

    test "an invalid move is an error", context do
      board = Board.get_new(rows: 2, columns: 2)
      {:ok, sup} = Game.Supervisor.start_link(%{ game_id: context.test, board: board, user_ids: ["a"] })
      assert Game.Supervisor.queue_move(sup, user: "a", from: {0,0}, to: {0,-1}) == {:error, "Cannot move to this space"}
    end

    test "an invalid user->player is an error", context do
      board = Board.get_new(rows: 2, columns: 2)
      {:ok, sup} = Game.Supervisor.start_link(%{ game_id: context.test, board: board, user_ids: ["a"] })
      assert Game.Supervisor.queue_move(sup, user: "b", from: {0,0}, to: {0,1}) == {:error, "You are not in this game"}
    end
  end

  describe "clear_future_moves/2" do
    test "an invalid user->player is an error", context do
      board = Board.get_new(rows: 2, columns: 2)
      {:ok, sup} = Game.Supervisor.start_link(%{ game_id: context.test, board: board, user_ids: ["a"] })
      assert Game.Supervisor.clear_future_moves(sup, user: "b") == {:error, "You are not in this game"}
    end

    test "the future command queue for a player is cleared out", context do
      board = Board.get_new(rows: 2, columns: 2)
      {:ok, sup} = Game.Supervisor.start_link(%{ game_id: context.test, board: board, user_ids: ["a", "b"] })

      player_server = Game.Supervisor.get_player_server_pid(sup)
      board_server = Game.Supervisor.get_board_pid(sup)
      a_player = Game.PlayerServer.get_active_player_id(player_server, "a")
      b_player = Game.PlayerServer.get_active_player_id(player_server, "b")

      new_board = board
        |> Board.replace_cell({0, 0}, %Board.Cell{ row: 0, column: 0, owner: a_player, population_count: 3 })
        |> Board.replace_cell({1, 1}, %Board.Cell{ row: 1, column: 1, owner: a_player, population_count: 3 })
        |> Board.replace_cell({1, 0}, %Board.Cell{ row: 1, column: 0, owner: b_player, population_count: 3 })

      Game.BoardServer.set_board_for_testing(board_server, new_board)

      queue_pid = Game.Supervisor.get_command_queue_pid(sup)
      assert Game.Supervisor.queue_move(sup, user: "a", from: {0,0}, to: {0,1}) == :ok
      assert Game.Supervisor.queue_move(sup, user: "a", from: {1,1}, to: {0,1}) == :ok
      assert Game.Supervisor.queue_move(sup, user: "b", from: {1,0}, to: {1,1}) == :ok
      assert length(Game.CommandQueueServer.commands_for_turn(queue_pid, 1)) == 2
      assert length(Game.CommandQueueServer.commands_for_turn(queue_pid, 2)) == 1
      assert Game.Supervisor.clear_future_moves(sup, user: "a") == :ok
    end
  end

  describe "serialize_game/2" do
    test "the right keys are included", context do
      board = Board.get_new(rows: 2, columns: 2)
      {:ok, sup} = Game.Supervisor.start_link(%{ game_id: context.test, board: board, user_ids: ["a", "b"] })
      serialized = Game.Supervisor.serialize_game(sup, user: "a")

      assert Map.keys(serialized) == [:board, :players, :turn]
      assert serialized[:turn] == 0
      assert serialized[:players] == ["a", "b"]
    end
  end
end
