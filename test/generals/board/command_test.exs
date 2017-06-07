defmodule Generals.Board.CommandTest do
  use ExUnit.Case, async: true

  alias Generals.Board.Command
  alias Generals.Board.Dimensions

  describe "get_move_command/1" do
    @invalid {:error, "Invalid move coordinates"}

    test "a valid command is returned" do
      assert Command.get_move_command(player: 1, coords: {1, 1}, dimensions: %Dimensions{ rows: 2, columns: 2 }) == %Command{
        player: 1,
        coords: {1,1},
        type: :move
      }
    end

    test "an invalid coord will be an error" do
      assert Command.get_move_command(player: 1, coords: {1}, dimensions: %Dimensions{ rows: 2, columns: 2 }) == @invalid
    end

    test "the r,c must be inside of the dimensions" do
      assert Command.get_move_command(player: 1, coords: {-1,0}, dimensions: %Dimensions{ rows: 2, columns: 2 }) == @invalid
      assert Command.get_move_command(player: 1, coords: {2,1}, dimensions: %Dimensions{ rows: 2, columns: 2 }) == @invalid
      assert Command.get_move_command(player: 1, coords: {1,2}, dimensions: %Dimensions{ rows: 2, columns: 2 }) == @invalid
      assert Command.get_move_command(player: 1, coords: {0,-1}, dimensions: %Dimensions{ rows: 2, columns: 2 }) == @invalid

      assert Command.get_move_command(player: 1, coords: {0,0}, dimensions: %Dimensions{ rows: 2, columns: 2 }) != @invalid
      assert Command.get_move_command(player: 1, coords: {1,1}, dimensions: %Dimensions{ rows: 2, columns: 2 }) != @invalid
    end
  end

  describe "execute/2" do

  end
end
