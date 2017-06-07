defmodule Generals.Game.SupervisorTest do
  use ExUnit.Case, async: true

  alias Generals.Board
  alias Generals.Game

  test "the board is initialized with a provided board", context do
    board = Board.get_new(rows: 1, columns: 1)
    {:ok, sup} = Game.Supervisor.start_link(%{ game_id: context, board: board })
    board_pid = Game.Supervisor.get_board_pid(sup)
    assert is_pid(board_pid)
    assert Game.BoardServer.get_board(board_pid) == board
  end

  test "the board is ticked correctly", context do
    board = Board.get_new(rows: 1, columns: 1)
      |> Board.replace_cell({0, 0}, %Board.Cell{ row: 0, column: 0, type: :general, owner: 1 })

    {:ok, sup} = Game.Supervisor.start_link(%{ game_id: context, board: board, timeout: 10 })
    board_pid = Game.Supervisor.get_board_pid(sup)

    assert Game.BoardServer.get_board(board_pid).cells == [[%Board.Cell{ column: 0, row: 0, owner: 1, population_count: 0, type: :general }]]
    Process.sleep(11)
    assert Game.BoardServer.get_board(board_pid).cells == [[%Board.Cell{ column: 0, row: 0, owner: 1, population_count: 1, type: :general }]]
  end
end
