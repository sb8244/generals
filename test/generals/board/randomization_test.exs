defmodule Generals.Board.RandomizationTest do
  use ExUnit.Case, async: true

  alias Generals.Board

  setup do
    board = Board.get_new(rows: 10, columns: 15)
    {:ok, board: board}
  end

  describe "generals" do
    test "there are exactly player_count generals on the map", %{ board: board } do
      random_board = Board.randomize_board(board, %Board.GenerationStats{ player_count: 3 })

      cells = List.flatten(random_board.cells)
      assert Enum.filter(cells, &(&1.type == :general))
        |> length == 3
    end

    test "generals can't be placed on top of each other" do
      board = Board.get_new(rows: 2, columns: 2)
      random_board = Board.randomize_board(board, %Board.GenerationStats{ player_count: 4 })
      assert random_board.cells |> List.flatten |> Enum.filter(&(&1.type == :general)) |> length == 4
    end
  end

  describe "mountains" do
    test "mountains won't be placed on top of each other"

    test "0 mountain percent range leads to no mountains" do
      board = Board.get_new(rows: 2, columns: 2)
      random_board = Board.randomize_board(board, %Board.GenerationStats{ player_count: 0, mountain_percent_range: (0..0) })
      assert List.flatten(random_board.cells) |> Enum.filter(&(&1.type == :mountain))
        |> length == 0
    end

    test "a positive mountain percent range leads to mountains in that range" do
      board = Board.get_new(rows: 10, columns: 10)
      Enum.each((1..100), fn(_) ->
        random_board = Board.randomize_board(board, %Board.GenerationStats{ player_count: 0, mountain_percent_range: (2..10) })
        mountain_count = random_board.cells |> List.flatten |> Enum.filter(&(&1.type == :mountain)) |> length
        assert mountain_count >= 2
        assert mountain_count <= 10
      end)
    end

    test "maps that can't be generated without mountains blocking the map results in an error"
  end

  describe "towns" do
    test "towns can't be placed on top of each other"
  end
end
