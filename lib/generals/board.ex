defmodule Generals.Board do
  alias Generals.Board
  alias Board.Cell
  alias Board.Dimensions
  alias Board.TurnRules

  defstruct cells: [], dimensions: %Dimensions{}, turn_rules: %TurnRules{}

  def get_new(rows: rows, columns: columns) do
    empty_cells = matrix_of_cells(rows: rows, columns: columns)
    %__MODULE__{ cells: empty_cells, dimensions: %Dimensions{ rows: rows, columns: columns } }
  end

  def tick(board = %Board{}, turn) do
    List.flatten(board.cells) |> Enum.reduce(board, fn(cell, next_board) ->
      ticked_cell = cond do
        cell.type == :general && TurnRules.tick_matches(turn, board.turn_rules, :general) -> Cell.tick_population(cell)
        cell.type == :town && TurnRules.tick_matches(turn, board.turn_rules, :town) && cell.owner != nil -> Cell.tick_population(cell)
        cell.type == :plains && TurnRules.tick_matches(turn, board.turn_rules, :plains) && cell.owner != nil && cell.population_count > 0 -> Cell.tick_population(cell)
        true -> cell
      end
      Board.replace_cell(next_board, Cell.coords(cell), ticked_cell)
    end)
  end

  def randomize_board(board = %Board{}, generation_stats, opts \\ []) do
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

  def convert_owner_on_all_owned_cells(board, from: from, to: to) do
    new_cells = Enum.map(board.cells, fn(row) ->
      Enum.map(row, fn(cell) ->
        case cell.owner == from do
          true -> Map.put(cell, :owner, to)
          false -> cell
        end
      end)
    end)
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
