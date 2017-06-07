defmodule Generals.Board.CommandTest do
  use ExUnit.Case, async: true

  alias Generals.Board
  alias Generals.Board.Command

  describe "get_move_command/1" do
    @invalid {:error, "Invalid move coordinates"}

    setup do
      board = Generals.Board.get_new(rows: 3, columns: 3)
      mountain_board = Board.replace_cell(board, {1,1}, %Board.Cell{ row: 1, column: 1, type: :mountain })

      {:ok, board: board, mountain_board: mountain_board}
    end

    test "a valid command is returned", %{ board: board } do
      assert Command.get_move_command(player: 1, from: {0,0}, to: {0, 1}, board: board) == %Command{
        player: 1,
        from: {0,0},
        to: {0,1},
        type: :move
      }
    end

    test "an invalid coord will be an error", %{ board: board } do
      assert Command.get_move_command(player: 1, from: {0,0}, to: {1}, board: board) == @invalid
    end

    test "the r,c must be inside of the dimensions", %{ board: board } do
      assert Command.get_move_command(player: 1, from: {0,0}, to: {-1,0}, board: board) == @invalid
      assert Command.get_move_command(player: 1, from: {2,1}, to: {3,1}, board: board) == @invalid
      assert Command.get_move_command(player: 1, from: {1,2}, to: {1,3}, board: board) == @invalid
      assert Command.get_move_command(player: 1, from: {0,0}, to: {0,-1}, board: board) == @invalid

      assert Command.get_move_command(player: 1, from: {0,1}, to: {0,0}, board: board) != @invalid
      assert Command.get_move_command(player: 1, from: {2,1}, to: {2,2}, board: board) != @invalid
    end

    test "the from and to must be manhattan adjacent", %{board: board} do
      assert Command.get_move_command(player: 1, from: {0,0}, to: {1,1}, board: board) == @invalid
      assert Command.get_move_command(player: 1, from: {2,2}, to: {1,1}, board: board) == @invalid
      assert Command.get_move_command(player: 1, from: {0,2}, to: {1,1}, board: board) == @invalid
      assert Command.get_move_command(player: 1, from: {2,0}, to: {1,1}, board: board) == @invalid

      assert Command.get_move_command(player: 1, from: {0,1}, to: {1,1}, board: board) != @invalid
      assert Command.get_move_command(player: 1, from: {1,0}, to: {1,1}, board: board) != @invalid
      assert Command.get_move_command(player: 1, from: {2,1}, to: {1,1}, board: board) != @invalid
      assert Command.get_move_command(player: 1, from: {1,2}, to: {1,1}, board: board) != @invalid
    end

    test "the move cannot be made onto a mountain", %{mountain_board: board} do
      assert Command.get_move_command(player: 1, from: {0,1}, to: {1,1}, board: board) == @invalid
    end
  end
end
