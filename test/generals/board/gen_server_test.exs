defmodule Generals.Board.GenServerTest do
  use ExUnit.Case, async: false

  import Mock

  alias Generals.Board

  setup do
    board = Board.get_new(rows: 2, columns: 2)
    {:ok, pid} = Board.GenServer.start_link(board)
    {:ok, pid: pid, board: board}
  end

  describe "get_board/1" do
    test "the board is returned", %{ pid: pid, board: board } do
      assert Board.GenServer.get_board(pid) == board
    end
  end

  describe "tick/1" do
    test "the turn is increased", %{pid: pid} do
      %{ turn: turn1 } = Board.GenServer.tick(pid)
      assert turn1 == 1

      %{ turn: turn2 } = Board.GenServer.tick(pid)
      assert turn2 == 2
    end

    test "the board undergoes a tick", %{pid: pid, board: board} do
      with_mock Board, [get_new: fn(_) -> board end, tick: fn(_, _) -> :next_board end] do
        %{ board: :next_board } = Board.GenServer.tick(pid)
        assert called(Board.tick(board, 1))
      end
    end
  end
end
