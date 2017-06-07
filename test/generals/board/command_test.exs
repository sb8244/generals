defmodule Generals.Board.CommandTest do
  use ExUnit.Case, async: true

  alias Generals.Board
  alias Generals.Board.Command

  describe "get_move_command/1" do
    @invalid {:error, "Invalid move coordinates"}

    setup do
      board = Generals.Board.get_new(rows: 3, columns: 3)
        |> Board.replace_cell({1,1}, %Board.Cell{ row: 1, column: 1, type: :mountain })

      {:ok, board: board}
    end

    test "a valid command is returned", %{ board: board } do
      assert Command.get_move_command(player: 1, coords: {0, 1}, board: board) == %Command{
        player: 1,
        coords: {0,1},
        type: :move
      }
    end

    test "an invalid coord will be an error", %{ board: board } do
      assert Command.get_move_command(player: 1, coords: {1}, board: board) == @invalid
    end

    test "the r,c must be inside of the dimensions", %{ board: board } do
      assert Command.get_move_command(player: 1, coords: {-1,0}, board: board) == @invalid
      assert Command.get_move_command(player: 1, coords: {3,1}, board: board) == @invalid
      assert Command.get_move_command(player: 1, coords: {1,3}, board: board) == @invalid
      assert Command.get_move_command(player: 1, coords: {0,-1}, board: board) == @invalid

      assert Command.get_move_command(player: 1, coords: {0,0}, board: board) != @invalid
      assert Command.get_move_command(player: 1, coords: {2,2}, board: board) != @invalid
    end

    test "the move cannot be made onto a mountain", %{board: board} do
      assert Command.get_move_command(player: 1, coords: {1,1}, board: board) == @invalid
    end
  end
end
