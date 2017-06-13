defmodule Generals.Board.BoardSerializer do
  alias Generals.Board
  alias Generals.Board.Cell

  def for_player(board, player: player) do
    %{
      rows: board.dimensions.rows,
      columns: board.dimensions.columns,
      cells: Enum.map(Board.get_player_visible_cells(board, player), &serialize/1)
    }
  end

  defp serialize(cell = %Cell{row: row, column: column, type: type}) do
    base = Map.take(cell, [:population_count, :owner])
    Map.merge(base, %{coords: {row, column}, type: to_string(type)})
  end
end
