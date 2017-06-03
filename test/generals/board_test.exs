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

  describe "at/2" do
    test "the right cell is returned" do
      board = Board.get_new(rows: 10, columns: 15)

      Enum.each((0..9), fn(r) ->
        Enum.each((0..14), fn(c) ->
          cell = Board.at(board, {r, c})
          assert Map.take(cell, [:row, :column]) == %{row: r, column: c}
        end)
      end)
    end
  end

  describe "special_type_coordinates/1" do
    test "a new board has no special type coordinates" do
      assert Board.get_new(rows: 2, columns: 2) |> Board.special_type_coordinates == []
    end

    test "placed coordinates appear in the list" do
      assert Board.get_new(rows: 3, columns: 3)
        |> Board.replace_cell({0, 0}, %Board.Cell{ row: 0, column: 0, type: :mountain })
        |> Board.replace_cell({1, 0}, %Board.Cell{ row: 1, column: 0, type: :town })
        |> Board.replace_cell({1, 1}, %Board.Cell{ row: 1, column: 1, type: :town })
        |> Board.replace_cell({2, 2}, %Board.Cell{ row: 2, column: 2, type: :general })
        |> Board.special_type_coordinates == [{0,0}, {1,0}, {1,1}, {2,2}]
    end
  end

  describe "replace_cell/3" do
    test "the board is returned with the cell replaced" do
      assert Board.get_new(rows: 2, columns: 2)
        |> Board.replace_cell({0, 0}, %Board.Cell{ row: 0, column: 0, type: :mountain })
        |> Map.take([:cells]) == %{
          cells: [
            [%Board.Cell{row: 0, column: 0, type: :mountain}, %Board.Cell{row: 0, column: 1}],
            [%Board.Cell{row: 1, column: 0}, %Board.Cell{row: 1, column: 1}],
          ]
        }
    end

    test "all boundaries are tested" do
      board = Board.get_new(rows: 2, columns: 3)
      Enum.each((0..1), fn(r) ->
        Enum.each((0..2), fn(c) ->
          assert board
            |> Board.replace_cell({r, c}, %Board.Cell{ row: r, column: c, type: :mountain })
            |> Board.at({r,c}) == %Board.Cell{ row: r, column: c, type: :mountain }
        end)
      end)
    end
  end
end
