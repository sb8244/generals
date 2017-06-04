defmodule Generals.Board.GenServerTest do
  use ExUnit.Case, async: true

  alias Generals.Board

  setup do
    board = Board.get_new(rows: 2, columns: 2)
    {:ok, pid} = Board.GenServer.start_link(board)
    {:ok, pid: pid, board: board}
  end

  describe "get_board/1" do
    test "the board is returned", %{ pid: pid, board: board } do
      assert Board.GenServer.get_board(pid) == board
    end
  end

  describe "tick/1" do
    test "the turn is increased", %{pid: pid} do
      %{ turn: turn1 } = Board.GenServer.tick(pid)
      assert turn1 == 1

      %{ turn: turn2 } = Board.GenServer.tick(pid)
      assert turn2 == 2
    end

    test "the board undergoes a tick" do
      board = Board.get_new(rows: 10, columns: 10)
        |> Board.replace_cell({0, 0}, %Board.Cell{ row: 0, column: 0, type: :general })
      {:ok, pid} = Board.GenServer.start_link(board)

      next_state = Board.GenServer.tick(pid)
      expected_next_board = Board.replace_cell(board, {0, 0}, %Board.Cell{ row: 0, column: 0, type: :general, population_count: 1 })
      assert next_state == %{
        turn: 1,
        board: expected_next_board
      }

      next_state = Board.GenServer.tick(pid)
      expected_next_board = Board.replace_cell(board, {0, 0}, %Board.Cell{ row: 0, column: 0, type: :general, population_count: 2 })
      assert next_state == %{
        turn: 2,
        board: expected_next_board
      }
    end
  end
end
