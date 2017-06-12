defmodule Generals.Game.BoardServerTest do
  use ExUnit.Case, async: true

  alias Generals.Board
  alias Generals.Game.BoardServer
  alias Generals.CommandQueue.Command

  setup do
    board = Board.get_new(rows: 2, columns: 2)
      |> Board.replace_cell({0,0}, %Board.Cell{row: 0, column: 0, type: :plains, owner: 1, population_count: 10})
      |> Board.replace_cell({1,0}, %Board.Cell{row: 0, column: 0, type: :plains, owner: 2, population_count: 20})

    {:ok, pid} = BoardServer.start_link(board)
    {:ok, pid: pid, board: board}
  end

  describe "get_board/1" do
    test "the board is returned", %{ pid: pid, board: board } do
      assert BoardServer.get_board(pid) == board
    end
  end

  describe "tick/1" do
    test "the turn is increased", %{pid: pid} do
      %{ turn: turn1 } = BoardServer.tick(pid)
      assert turn1 == 1

      %{ turn: turn2 } = BoardServer.tick(pid)
      assert turn2 == 2
    end

    test "the board undergoes a tick" do
      board = Board.get_new(rows: 10, columns: 10)
        |> Board.replace_cell({0, 0}, %Board.Cell{ row: 0, column: 0, type: :general })
      {:ok, pid} = BoardServer.start_link(board)

      return = BoardServer.tick(pid)
      expected_next_board = Board.replace_cell(board, {0, 0}, %Board.Cell{ row: 0, column: 0, type: :general, population_count: 1 })
      assert return == %{
        turn: 1,
        board: expected_next_board,
        changed_coords: [{0,0}]
      }

      return = BoardServer.tick(pid)
      expected_next_board = Board.replace_cell(board, {0, 0}, %Board.Cell{ row: 0, column: 0, type: :general, population_count: 2 })
      assert return == %{
        turn: 2,
        board: expected_next_board,
        changed_coords: [{0,0}]
      }
    end
  end

  describe "execute_command/2" do
    test "valid commands are executed without progressing the turn", %{pid: pid, board: board} do
      command = Command.get_move_command(player: 1, from: {0,0}, to: {0,1}, board: board)
      {:ok, %{board: board, turn: turn}} = BoardServer.execute_command(pid, command)
      assert turn == 0
      assert Board.at(board, {0,1}) |> Map.take([:owner]) == %{owner: 1}
    end

    test "invalid commands return an error without modifying state", %{pid: pid, board: board} do
      command = Command.get_move_command(player: 2, from: {1,0}, to: {0,0}, board: board)
      losing_command = Command.get_move_command(player: 1, from: {0,0}, to: {0,1}, board: board)
      {:ok, %{board: board, turn: turn}} = BoardServer.execute_command(pid, command)
      assert turn == 0
      assert Board.at(board, {0,0}) |> Map.take([:owner]) == %{owner: 2} # owner has changed from 1 -> 2, making move invalid
      {:invalid, %{board: _, turn: _}} = BoardServer.execute_command(pid, losing_command)
    end
  end
end
