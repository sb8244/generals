defmodule Generals.Board.BoardSerializer do
  alias Generals.Board
  alias Generals.Board.Cell

  def for_player(board, player: player) do
    %{
      rows: board.dimensions.rows,
      columns: board.dimensions.columns,
      cells: Enum.map(cells(board, player), &serialize/1),
      mountains: Enum.map(Board.get_cells(board, type: :mountain), &serialize/1),
    }
  end

  # TODO: Test
  def for_changes(board, player: player, changed_coords: changed_coords) do
    Enum.map(changed_cells(board, player, changed_coords), &serialize/1)
  end

  defp serialize(cell = %Cell{row: row, column: column, type: type}) do
    base = Map.take(cell, [:population_count, :owner])
    Map.merge(base, %{coords: %{row: row, column: column}, type: to_string(type)})
  end

  defp cells(board, player) do
    Board.get_player_visible_cells(board, player)
  end

  defp changed_cells(board, player, changed_coords) do
    Board.get_player_visible_cells(board, player, changed_coords) ++
    Board.get_player_visible_neighbor_cells(board, player, changed_coords)
  end
end
