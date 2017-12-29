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

  describe "tick/2" do
    test "occupied towns and all generals are increased by 1 on each turn" do
      %{board: board} = Board.get_new(rows: 10, columns: 10)
        |> Board.replace_cell({0, 0}, %Board.Cell{ row: 0, column: 0, type: :town, owner: 1, population_count: 0 })
        |> Board.replace_cell({0, 1}, %Board.Cell{ row: 0, column: 1, type: :general, owner: 1, population_count: 5 })
        |> Board.replace_cell({0, 2}, %Board.Cell{ row: 0, column: 2, type: :town, population_count: 0 })
        |> Board.tick(1 * Generals.Board.TurnRules.speedup_factor)

      assert Board.at(board, {0,0}) |> Map.take([:population_count]) == %{population_count: 1}
      assert Board.at(board, {0,1}) |> Map.take([:population_count]) == %{population_count: 6}
      assert Board.at(board, {0,2}) |> Map.take([:population_count]) == %{population_count: 0}
      assert Board.at(board, {0,3}) |> Map.take([:population_count]) == %{population_count: 0}

      %{board: board2} = Board.tick(board, 2 * Generals.Board.TurnRules.speedup_factor)

      assert Board.at(board2, {0,0}) |> Map.take([:population_count]) == %{population_count: 2}
      assert Board.at(board2, {0,1}) |> Map.take([:population_count]) == %{population_count: 7}
      assert Board.at(board2, {0,2}) |> Map.take([:population_count]) == %{population_count: 0}
      assert Board.at(board, {0,3}) |> Map.take([:population_count]) == %{population_count: 0}
    end

    test "the ticked cells are returned" do
      %{changed_coords: coords} = Board.get_new(rows: 10, columns: 10)
        |> Board.replace_cell({0, 0}, %Board.Cell{ row: 0, column: 0, type: :town, owner: 1, population_count: 0 })
        |> Board.replace_cell({0, 1}, %Board.Cell{ row: 0, column: 1, type: :general, owner: 1, population_count: 5 })
        |> Board.replace_cell({0, 2}, %Board.Cell{ row: 0, column: 2, type: :town, population_count: 0 })
        |> Board.tick(1 * Generals.Board.TurnRules.speedup_factor)

      assert Enum.sort(coords) == [{0,0}, {0,1}]
    end

    test "occupied plains are increased by 1 every 25 * speedup_factor turns" do
      board = Board.get_new(rows: 10, columns: 10)
        |> Board.replace_cell({0, 0}, %Board.Cell{ row: 0, column: 0, type: :plains, owner: 1, population_count: 1 })
        |> Board.replace_cell({0, 1}, %Board.Cell{ row: 0, column: 1, type: :plains, population_count: 1 })

      Enum.each((1..250), fn(i) ->
        if rem(i, Generals.Board.TurnRules.speedup_factor) > 0 do
          %{board: ticked_board} = Board.tick(board, i)
          assert Board.at(ticked_board, {0,0}) |> Map.take([:population_count]) == %{population_count: 1}
          assert Board.at(ticked_board, {0,1}) |> Map.take([:population_count]) == %{population_count: 1}
        end
      end)

      Enum.each([25,50,75], fn(i) ->
        %{board: ticked_board} = Board.tick(board, i * Generals.Board.TurnRules.speedup_factor)
        assert Board.at(ticked_board, {0,0}) |> Map.take([:population_count]) == %{population_count: 2}
        assert Board.at(ticked_board, {0,1}) |> Map.take([:population_count]) == %{population_count: 1}
      end)
    end

    test "plains with 0 population are not ticked" do
      %{board: board} = Board.get_new(rows: 10, columns: 10)
        |> Board.replace_cell({0, 0}, %Board.Cell{ row: 0, column: 0, type: :plains, owner: 1, population_count: 0 })
        |> Board.tick(25)
      assert Board.at(board, {0,0}) |> Map.take([:population_count]) == %{population_count: 0}
    end
  end

  describe "convert_owner_on_all_owned_cells/2" do
    test "all cells for the 'from' owner are replaced by the 'to' owner" do
      board = Board.get_new(rows: 3, columns: 3)
        |> Board.replace_cell({0, 0}, %Board.Cell{ row: 0, column: 0, type: :plains, owner: 1, population_count: 0 })
        |> Board.replace_cell({0, 1}, %Board.Cell{ row: 0, column: 1, type: :town, owner: 1, population_count: 1 })
        |> Board.replace_cell({0, 2}, %Board.Cell{ row: 0, column: 2, type: :general, owner: 1, population_count: 2 })
        |> Board.replace_cell({1, 2}, %Board.Cell{ row: 1, column: 2, type: :town, owner: 2, population_count: 2 })
      new_board = Board.convert_owner_on_all_owned_cells(board, from: 1, to: 2)
      assert Board.at(new_board, {0,0}) |> Map.take([:owner, :type, :population_count]) == %{owner: 2, population_count: 0, type: :plains}
      assert Board.at(new_board, {0,1}) |> Map.take([:owner, :type, :population_count]) == %{owner: 2, population_count: 1, type: :town}
      assert Board.at(new_board, {0,2}) |> Map.take([:owner, :type, :population_count]) == %{owner: 2, population_count: 2, type: :general}
      assert Board.at(new_board, {1,2}) |> Map.take([:owner, :type, :population_count]) == %{owner: 2, population_count: 2, type: :town}
    end
  end

  describe "get_player_visible_cells/2" do
    test "an invalid player id is an empty list" do
      board = Board.get_new(rows: 3, columns: 3)
        |> Board.replace_cell({0, 0}, %Board.Cell{ row: 0, column: 0, owner: 1 })

      assert Board.get_player_visible_cells(board, 2) == []
    end

    test "a 1x1 board returns all cells" do
      board = Board.get_new(rows: 1, columns: 1)
        |> Board.replace_cell({0, 0}, %Board.Cell{ row: 0, column: 0, owner: 1 })

      assert Board.get_player_visible_cells(board, 1) == [Board.at(board, {0, 0})]
    end

    test "neighboring cells are returned from a corner" do
      board = Board.get_new(rows: 3, columns: 3)
        |> Board.replace_cell({0, 0}, %Board.Cell{ row: 0, column: 0, owner: 1 })

      assert Board.get_player_visible_cells(board, 1)
        |> Enum.map(&({&1.row, &1.column})) == [{0, 0}, {0, 1}, {1, 0}]
    end

    test "multiple cells return neighbors without dupes" do
      board = Board.get_new(rows: 3, columns: 3)
        |> Board.replace_cell({1, 0}, %Board.Cell{ row: 1, column: 0, owner: 1 })
        |> Board.replace_cell({1, 1}, %Board.Cell{ row: 1, column: 1, owner: 1 })
        |> Board.replace_cell({1, 2}, %Board.Cell{ row: 1, column: 2, owner: 1 })

      assert Board.get_player_visible_cells(board, 1)
        |> Enum.map(&({&1.row, &1.column})) == [
          {0, 0}, {0, 1}, {0, 2},
          {1, 0}, {1, 1}, {1, 2},
          {2, 0}, {2, 1}, {2, 2}
        ] # full board without dupes
    end

    test "neighboring cells are returned from a middle piece" do
      board = Board.get_new(rows: 3, columns: 3)
        |> Board.replace_cell({1, 1}, %Board.Cell{ row: 1, column: 1, owner: 1 })

      assert Board.get_player_visible_cells(board, 1) |> Enum.map(&({&1.row, &1.column})) == [
        {0, 1},
        {1, 0},
        {1, 1},
        {1, 2},
        {2, 1}
      ]
    end

    test "enemy cells are returned" do
      board = Board.get_new(rows: 3, columns: 3)
        |> Board.replace_cell({1, 1}, %Board.Cell{ row: 1, column: 1, owner: 1 })
        |> Board.replace_cell({1, 2}, %Board.Cell{ row: 1, column: 2, owner: 2 })

      assert Board.get_player_visible_cells(board, 1) |> Enum.map(&({&1.row, &1.column})) == [
        {0, 1},
        {1, 0},
        {1, 1}, # self
        {1, 2}, # enemy
        {2, 1}
      ]

      assert Board.get_player_visible_cells(board, 2) |> Enum.map(&({&1.row, &1.column})) == [
        {0, 2},
        {1, 1}, # enemy
        {1, 2}, # self
        {2, 2}
      ]
    end
  end
end
