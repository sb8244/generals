defmodule Generals.Game.SupervisorTest do
  use ExUnit.Case, async: true

  alias Generals.Board
  alias Generals.Game

  test "the board is initialized with a provided board", context do
    board = Board.get_new(rows: 1, columns: 1)
    {:ok, sup} = Game.Supervisor.start_link(%{ game_id: context, board: board, user_ids: ["a"] })
    board_pid = Game.Supervisor.get_board_pid(sup)
    assert is_pid(board_pid)
    assert Game.BoardServer.get_board(board_pid) == board
  end

  test "the board is ticked correctly", context do
    board = Board.get_new(rows: 1, columns: 1)
      |> Board.replace_cell({0, 0}, %Board.Cell{ row: 0, column: 0, type: :general, owner: 1 })

    {:ok, sup} = Game.Supervisor.start_link(%{ game_id: context, board: board, timeout: 10, user_ids: ["a"] })
    board_pid = Game.Supervisor.get_board_pid(sup)

    assert Game.BoardServer.get_board(board_pid).cells == [[%Board.Cell{ column: 0, row: 0, owner: 1, population_count: 0, type: :general }]]
    Process.sleep(15)
    assert Game.BoardServer.get_board(board_pid).cells == [[%Board.Cell{ column: 0, row: 0, owner: 1, population_count: 1, type: :general }]]
  end

  test "commands for a turn are executed on a tick", context do
    board = Board.get_new(rows: 2, columns: 2)
      |> Board.replace_cell({0, 0}, %Board.Cell{ row: 0, column: 0, owner: 1, population_count: 3 })

    {:ok, sup} = Game.Supervisor.start_link(%{ game_id: context, board: board, timeout: 20, user_ids: ["a"] })
    assert Game.Supervisor.queue_move(sup, player: 1, from: {0,0}, to: {0,1}) == :ok

    board_pid = Game.Supervisor.get_board_pid(sup)
    assert Game.BoardServer.get_board(board_pid)
      |> Board.at({0,1})
      |> Map.take([:owner, :population_count]) == %{owner: nil, population_count: 0}

    Process.sleep(30)

    %{board: board, turn: turn} = Game.BoardServer.get(board_pid)

    assert turn == 1
    assert board
      |> Board.at({0,1})
      |> Map.take([:owner, :population_count]) == %{owner: 1, population_count: 2}
  end

  describe "queue_move/2" do
    test "the command queue has the given move added as a command", context do
      board = Board.get_new(rows: 2, columns: 2)
        |> Board.replace_cell({0, 0}, %Board.Cell{ row: 0, column: 0, owner: 1, population_count: 3 })

      {:ok, sup} = Game.Supervisor.start_link(%{ game_id: context, board: board, user_ids: ["a"] })
      assert Game.Supervisor.queue_move(sup, player: 1, from: {0,0}, to: {0,1}) == :ok

      queue_pid = Game.Supervisor.get_command_queue_pid(sup)
      assert length(Game.CommandQueueServer.commands_for_turn(queue_pid, 1)) == 1
    end

    test "an invalid move is an error", context do
      board = Board.get_new(rows: 2, columns: 2)
      {:ok, sup} = Game.Supervisor.start_link(%{ game_id: context, board: board, user_ids: ["a"] })
      assert Game.Supervisor.queue_move(sup, player: 1, from: {0,0}, to: {0,1}) == {:error, "Cannot move from a space you don't hold"}
    end
  end

  describe "clear_future_moves/2" do
    test "the future command queue for a player is cleared out", context do
      board = Board.get_new(rows: 2, columns: 2)
        |> Board.replace_cell({0, 0}, %Board.Cell{ row: 0, column: 0, owner: 1, population_count: 3 })
        |> Board.replace_cell({1, 1}, %Board.Cell{ row: 1, column: 1, owner: 1, population_count: 3 })
        |> Board.replace_cell({1, 0}, %Board.Cell{ row: 1, column: 0, owner: 2, population_count: 3 })
      {:ok, sup} = Game.Supervisor.start_link(%{ game_id: context, board: board, user_ids: ["a"] })
      queue_pid = Game.Supervisor.get_command_queue_pid(sup)
      assert Game.Supervisor.queue_move(sup, player: 1, from: {0,0}, to: {0,1}) == :ok
      assert Game.Supervisor.queue_move(sup, player: 1, from: {1,1}, to: {0,1}) == :ok
      assert Game.Supervisor.queue_move(sup, player: 2, from: {1,0}, to: {1,1}) == :ok
      assert length(Game.CommandQueueServer.commands_for_turn(queue_pid, 1)) == 2
      assert length(Game.CommandQueueServer.commands_for_turn(queue_pid, 2)) == 1
      assert Game.Supervisor.clear_future_moves(sup, player: 1) == :ok
    end
  end
end
