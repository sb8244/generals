defmodule Generals.Board do
  alias Generals.Board
  alias Board.Cell
  alias Board.Dimensions

  defstruct cells: [], dimensions: %Dimensions{}

  def get_new(rows: rows, columns: columns) do
    empty_cells = matrix_of_cells(rows: rows, columns: columns)
    %__MODULE__{ cells: empty_cells, dimensions: %Dimensions{ rows: rows, columns: columns } }
  end

  def randomize_board(board, generation_stats, opts \\ []) do
    options = Keyword.merge([randomization_strategy: Board.BasicRandomization], opts)
    options[:randomization_strategy].randomize_board(board, generation_stats)
  end

  def at(board, {row, col}) do
    board.cells |> Enum.at(row) |> Enum.at(col)
  end

  def special_type_coordinates(board) do
    List.flatten(board.cells) |> Enum.filter(&(&1.type != :plains)) |> Enum.map(fn(cell) ->
      {cell.row, cell.column}
    end)
  end

  def replace_cell(board, {row, col}, cell) do
    new_col = List.replace_at(Enum.at(board.cells, row), col, cell)
    new_cells = List.replace_at(board.cells, row, new_col)
    Map.put(board, :cells, new_cells)
  end

  defp matrix_of_cells(rows: rows, columns: columns) do
    Enum.map((0..rows-1), fn(r) ->
      Enum.map((0..columns-1), fn(c) ->
        %Cell{ row: r, column: c }
      end)
    end)
  end
end
