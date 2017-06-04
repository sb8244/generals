defmodule Generals.GamesSupervisorTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, pid} = Generals.GamesSupervisor.start_link(name: nil)
    {:ok, supervisor: pid}
  end

  describe "get_game/1" do
    test "a new game supervisor is started if it doesn't exist already", %{ supervisor: sup } do
      game_1 = Generals.GamesSupervisor.get_game(1, name: sup)
      assert is_pid(game_1)
    end

    test "an existing game supervisor is returned if it existed already", %{ supervisor: sup } do
      game_1a = Generals.GamesSupervisor.get_game(1, name: sup)
      game_1b = Generals.GamesSupervisor.get_game(1, name: sup)

      assert is_pid(game_1a) && is_pid(game_1b)
      assert game_1a == game_1b
    end

    test "games are identified by their id", %{ supervisor: sup } do
      game_1 = Generals.GamesSupervisor.get_game(1, name: sup)
      game_2 = Generals.GamesSupervisor.get_game(2, name: sup)

      assert is_pid(game_1)
      assert is_pid(game_2)
      assert game_1 != game_2
    end
  end
end
