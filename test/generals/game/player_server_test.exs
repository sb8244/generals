defmodule Generals.Game.PlayerServerTest do
  use ExUnit.Case, async: true

  alias Generals.Game.PlayerServer

  test "the player list is initialized with a list of user ids and creates player ids for them" do
    user_ids = ["a123", "b234", "c345", "d456"]
    {:ok, pid} = PlayerServer.start_link([user_ids: user_ids])
    Agent.get(pid, fn(map) ->
      assert Map.values(map) |> Enum.sort |> List.first == %{left: false, player_id: 0}
      assert Map.keys(map) == user_ids
    end)
  end

  describe "get_active_player_id/2" do
    test "returns false without the user id in this game" do
      {:ok, pid} = PlayerServer.start_link([user_ids: ["a", "b"]])
      assert PlayerServer.get_active_player_id(pid, "c") == nil
    end

    test "returns true without the user id in this game" do
      {:ok, pid} = PlayerServer.start_link([user_ids: ["a", "b"]])
      mapping_a = PlayerServer.get_active_player_id(pid, "a")
      mapping_b = PlayerServer.get_active_player_id(pid, "b")
      assert (mapping_a == 0 || mapping_a == 1) && (mapping_b == 0 || mapping_b == 1)
      assert mapping_a != mapping_b
    end

    test "returns false for an id that has left the game" do
      {:ok, pid} = PlayerServer.start_link([user_ids: ["a", "b"]])
      PlayerServer.user_left(pid, "a")
      assert PlayerServer.get_active_player_id(pid, "a") == nil
      assert is_number(PlayerServer.get_active_player_id(pid, "b"))
    end
  end

  describe "user_left/2" do
    test "a user who isn't in the game won't mess up state" do
      {:ok, pid} = PlayerServer.start_link([user_ids: ["a", "b"]])
      assert PlayerServer.user_left(pid, "c") == false
      assert is_number(PlayerServer.get_active_player_id(pid, "a"))
      assert is_number(PlayerServer.get_active_player_id(pid, "b"))
      Agent.get(pid, fn(map) ->
        assert Map.keys(map) == ["a", "b"]
      end)
    end

    test "a user who is in the game is marked as left" do
      {:ok, pid} = PlayerServer.start_link([user_ids: ["a", "b"]])
      assert PlayerServer.user_left(pid, "b") == true
      assert is_number(PlayerServer.get_active_player_id(pid, "a"))
      assert PlayerServer.get_active_player_id(pid, "b") == nil
      Agent.get(pid, fn(map) ->
        assert Map.keys(map) == ["a", "b"]
      end)
    end
  end
end
