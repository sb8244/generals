defmodule Generals.GameTest do
  use ExUnit.Case, async: true

  describe "create_game/1" do
    test "a game is created for the user" do
      {:ok, id, pid} = Generals.Game.create_game("my-id")
      assert is_pid(pid)
      assert is_bitstring(id)
    end
  end

  describe "find_user_game/1" do
    test "{:ok, pid} is returned for a valid game" do
      {:ok, id, origpid} = Generals.Game.create_game("my-id")
      {:ok, pid} = Generals.Game.find_user_game(game_id: id, user_id: "my-id")

      assert pid == origpid && is_pid(pid)
    end

    test "{:error, why} is returned for an invalid game" do
      {:error, "This is not a game"} = Generals.Game.find_user_game(game_id: 1, user_id: "my-id")
    end

    test "{:error, why} is returned for an inaccessible game" do
      {:ok, id, _} = Generals.Game.create_game("my-id")
      {:error, "This is not a game"} = Generals.Game.find_user_game(game_id: id, user_id: "denied")
    end
  end
end
