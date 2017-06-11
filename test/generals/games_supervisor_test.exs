defmodule Generals.GamesSupervisorTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, pid} = Generals.GamesSupervisor.start_link(name: nil)
    board = Generals.Board.get_new(rows: 10, columns: 10)
    {:ok, supervisor: pid, board: board}
  end

  describe "get_game/1" do
    @tag :focus
    test "nil is returned if it doesn't exist already", %{ supervisor: sup } do
      assert Generals.GamesSupervisor.get_game(1, name: sup) == nil
    end

    @tag :focus
    test "games are identified by their id", %{ supervisor: sup, board: board } do
      Generals.GamesSupervisor.start_game(1, name: sup, board: board, user_ids: ["a", "b"])
      Generals.GamesSupervisor.start_game(2, name: sup, board: board, user_ids: ["a", "b"])
      game_1 = Generals.GamesSupervisor.get_game(1, name: sup)
      game_2 = Generals.GamesSupervisor.get_game(2, name: sup)

      assert is_pid(game_1)
      assert is_pid(game_2)
      assert game_1 != game_2
    end
  end

  describe "start_game/1" do
    test "an existing game supervisor returns an error if already started", %{ supervisor: sup, board: board } do
      game_1a = Generals.GamesSupervisor.start_game(1, name: sup, board: board, user_ids: ["a", "b"])
      game_1b = Generals.GamesSupervisor.start_game(1, name: sup, board: board, user_ids: ["a", "b"])
      assert is_pid(game_1a) && !is_pid(game_1b)
      assert game_1b == {:error, "Game with this ID already exists"}
    end
  end
end
