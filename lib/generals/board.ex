defmodule Generals.Board do
  alias Generals.Board.Cell
  alias Generals.Board.Dimensions

  defstruct cells: [], dimensions: %Dimensions{}

  def get_new(rows: rows, columns: columns) do
    empty_cells = matrix_of_cells(rows: rows, columns: columns)
    %__MODULE__{ cells: empty_cells, dimensions: %Dimensions{ rows: rows, columns: columns } }
  end

  def randomize_board(board, player_count: player_count) do
    Enum.reduce(1..player_count, {board, []}, fn(player_id, {board, placed_general_coords}) ->
      {row, col} = Dimensions.random_coordinates(board.dimensions, exclude: placed_general_coords)
      existing_cell = at(board, {row, col})
      new_cell = Cell.make_general(existing_cell, owner: player_id)
      {
        replace_cell(board, {row, col}, new_cell),
        [{row, col} | placed_general_coords]
      }
    end) |> elem(0)
  end

  defp at(board, {row, col}) do
    board.cells |> Enum.at(row) |> Enum.at(col)
  end

  defp replace_cell(board, {row, col}, cell) do
    new_col = List.replace_at(Enum.at(board.cells, row), col, cell)
    new_cells = List.replace_at(board.cells, row, new_col)
    Map.put(board, :cells, new_cells)
  end

  defp matrix_of_cells(rows: rows, columns: columns) do
    Enum.map((1..rows), fn(_) ->
      Enum.map((1..columns), fn(_) ->
        %Cell{}
      end)
    end)
  end
end
