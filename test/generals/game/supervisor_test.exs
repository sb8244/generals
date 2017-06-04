defmodule Generals.Game.SupervisorTest do
  use ExUnit.Case, async: true

  alias Generals.Board
  alias Generals.Game

  describe "the initial state of the board" do
    test "the board is initialized with a provided board" do
      board = Board.get_new(rows: 1, columns: 1)
      {:ok, sup} = Game.Supervisor.start_link(%{ game_id: 1, board: board })
      board_pid = Game.Supervisor.get_board_pid(sup)
      assert is_pid(board_pid)
      assert Board.GenServer.get_board(board_pid) == board
    end
  end
end
