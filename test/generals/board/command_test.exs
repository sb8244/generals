defmodule Generals.Board.CommandTest do
  use ExUnit.Case, async: true

  alias Generals.Board
  alias Generals.Board.Command

  describe "get_move_command/1" do
    @invalid {:error, "Cannot move to this space"}
    @invalid_player {:error, "Cannot move from a space you don't hold"}

    setup do
      board = Generals.Board.get_new(rows: 3, columns: 3)
      owned_cells = Enum.map(board.cells, fn(row) ->
        Enum.map(row, &(Map.put(&1, :owner, 1)))
      end)
      board = Map.merge(board, %{cells: owned_cells})

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

    test "the moving player must own the space they are moving from", %{board: board} do
      unowned_board = Board.replace_cell(board, {0,0}, %Board.Cell{ row: 0, column: 0, owner: nil })
      assert Command.get_move_command(player: 1, from: {0,0}, to: {0, 1}, board: unowned_board) == @invalid_player
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

  describe "execute_command/2" do
    setup do
      board = Generals.Board.get_new(rows: 3, columns: 3)
        |> Board.replace_cell({1,1}, %Board.Cell{ row: 1, column: 1, type: :plains, owner: 1, population_count: 10 })
      {:ok, board: board}
    end

    test "moving from a location which you don't own is an error", %{board: board} do
      command = Command.get_move_command(player: 1, from: {1,1}, to: {1,2}, board: board)
      unowned_space_board = Board.replace_cell(board, {1,1}, %Board.Cell{ row: 1, column: 1, type: :plains, owner: 2 })
      assert Command.execute(command, unowned_space_board) == {:error, "Cannot move from a space you don't hold"}
    end

    test "moving onto a plains -> gains n-1 army on plains, leaves 1 army behind", %{board: board} do
      command = Command.get_move_command(player: 1, from: {1,1}, to: {1,2}, board: board)
      {:ok, new_board} = Command.execute(command, board)
      assert Board.at(new_board, {1,1}) == %Board.Cell{row: 1, column: 1, type: :plains, owner: 1, population_count: 1}
      assert Board.at(new_board, {1,2}) == %Board.Cell{row: 1, column: 2, type: :plains, owner: 1, population_count: 9}
    end

    Enum.each([0, 1], fn(count) ->
      test "moving with #{count} armies is a no-op", %{board: board} do
        command = Command.get_move_command(player: 1, from: {1,1}, to: {1,2}, board: board)
        check_board = board
          |> Board.replace_cell({1,1}, %Board.Cell{ row: 1, column: 1, type: :plains, owner: 1, population_count: unquote(count) })
          |> Board.replace_cell({1,2}, %Board.Cell{ row: 1, column: 2, type: :town, owner: 2, population_count: 5 })
        {:ok, new_board} = Command.execute(command, check_board)
        assert Board.at(new_board, {1,1}) == %Board.Cell{row: 1, column: 1, type: :plains, owner: 1, population_count: unquote(count)}
        assert Board.at(new_board, {1,2}) == %Board.Cell{row: 1, column: 2, type: :town, owner: 2, population_count: 5}
      end
    end)

    # test "moving with a percentage will split the army up, moving only the percentage to the plain"

    test "moving onto a town which is less health will overtake the town for the player", %{board: board} do
      command = Command.get_move_command(player: 1, from: {1,1}, to: {1,2}, board: board)
      check_board = board
        |> Board.replace_cell({1,1}, %Board.Cell{ row: 1, column: 1, type: :plains, owner: 1, population_count: 10 })
        |> Board.replace_cell({1,2}, %Board.Cell{ row: 1, column: 2, type: :town, owner: 2, population_count: 5 })
      {:ok, new_board} = Command.execute(command, check_board)
      assert Board.at(new_board, {1,1}) == %Board.Cell{row: 1, column: 1, type: :plains, owner: 1, population_count: 1}
      assert Board.at(new_board, {1,2}) == %Board.Cell{row: 1, column: 2, type: :town, owner: 1, population_count: 4}
    end

    test "moving onto a town which is more health will leave the town with reduced population", %{board: board} do
      command = Command.get_move_command(player: 1, from: {1,1}, to: {1,2}, board: board)
      check_board = board
        |> Board.replace_cell({1,1}, %Board.Cell{ row: 1, column: 1, type: :plains, owner: 1, population_count: 5 })
        |> Board.replace_cell({1,2}, %Board.Cell{ row: 1, column: 2, type: :town, owner: 2, population_count: 10 })
      {:ok, new_board} = Command.execute(command, check_board)
      assert Board.at(new_board, {1,1}) == %Board.Cell{row: 1, column: 1, type: :plains, owner: 1, population_count: 1}
      assert Board.at(new_board, {1,2}) == %Board.Cell{row: 1, column: 2, type: :town, owner: 2, population_count: 6}
    end

    test "moving onto a town which is equal health will leave the town with 0 population", %{board: board} do
      command = Command.get_move_command(player: 1, from: {1,1}, to: {1,2}, board: board)
      check_board = board
        |> Board.replace_cell({1,1}, %Board.Cell{ row: 1, column: 1, type: :plains, owner: 1, population_count: 6 })
        |> Board.replace_cell({1,2}, %Board.Cell{ row: 1, column: 2, type: :town, owner: 2, population_count: 5 })
      {:ok, new_board} = Command.execute(command, check_board)
      assert Board.at(new_board, {1,1}) == %Board.Cell{row: 1, column: 1, type: :plains, owner: 1, population_count: 1}
      assert Board.at(new_board, {1,2}) == %Board.Cell{row: 1, column: 2, type: :town, owner: 2, population_count: 0}
    end

    test "moving onto a town owned by the same player will combine the forces", %{board: board} do
      command = Command.get_move_command(player: 1, from: {1,1}, to: {1,2}, board: board)
      check_board = board
        |> Board.replace_cell({1,1}, %Board.Cell{ row: 1, column: 1, type: :plains, owner: 1, population_count: 6 })
        |> Board.replace_cell({1,2}, %Board.Cell{ row: 1, column: 2, type: :town, owner: 1, population_count: 5 })
      {:ok, new_board} = Command.execute(command, check_board)
      assert Board.at(new_board, {1,1}) == %Board.Cell{row: 1, column: 1, type: :plains, owner: 1, population_count: 1}
      assert Board.at(new_board, {1,2}) == %Board.Cell{row: 1, column: 2, type: :town, owner: 1, population_count: 10}
    end

    test "moving onto an enemy general which is less health will take over the general, turning it into a town and converting all enemy pieces to the current player", %{board: board} do
      command = Command.get_move_command(player: 1, from: {1,1}, to: {1,2}, board: board)
      check_board = board
        |> Board.replace_cell({1,1}, %Board.Cell{ row: 1, column: 1, type: :plains, owner: 1, population_count: 10 })
        |> Board.replace_cell({1,2}, %Board.Cell{ row: 1, column: 2, type: :general, owner: 2, population_count: 5 })
        |> Board.replace_cell({0,0}, %Board.Cell{ row: 0, column: 0, type: :town, owner: 2, population_count: 5 })
        |> Board.replace_cell({1,0}, %Board.Cell{ row: 1, column: 0, type: :plains, owner: 2, population_count: 6 })
      {:ok, new_board} = Command.execute(command, check_board)
      assert Board.at(new_board, {1,1}) == %Board.Cell{row: 1, column: 1, type: :plains, owner: 1, population_count: 1}
      assert Board.at(new_board, {1,2}) == %Board.Cell{row: 1, column: 2, type: :town, owner: 1, population_count: 4}
      assert Board.at(new_board, {0,0}) == %Board.Cell{row: 0, column: 0, type: :town, owner: 1, population_count: 5}
      assert Board.at(new_board, {1,0}) == %Board.Cell{row: 1, column: 0, type: :plains, owner: 1, population_count: 6}
    end
  end
end
