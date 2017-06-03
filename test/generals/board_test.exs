defmodule Generals.BoardTest do
  use ExUnit.Case, async: true

  alias Generals.Board

  describe "get_new/1" do
    test "the correct dimensions are provided" do
      board = Board.get_new(rows: 10, columns: 10)
      assert board.dimensions == %Board.Dimensions{ rows: 10, columns: 10 }
    end

    test "the cells are created, but blank" do
      board = Board.get_new(rows: 10, columns: 5)
      assert length(board.cells) == 10
      Enum.each(board.cells, fn(l) ->
        assert length(l) == 5
        Enum.each(l, fn(cell) ->
          %Board.Cell{ population_count: 0, type: :plains, owner: nil, row: row, column: col } = cell
          assert row
          assert col
        end)
      end)
    end
  end

  describe "randomize_board/2" do
    test "there are exactly player_count generals on the map" do
      board = Board.get_new(rows: 10, columns: 15)
      random_board = Board.randomize_board(board, %Board.GenerationStats{ player_count: 3 })

      cells = List.flatten(random_board.cells)
      assert Enum.filter(cells, &(&1.type == :general))
        |> length == 3
    end
  end
end
