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
    List.flatten(board.cells) |> Enum.reduce(%{board: board, changed_coords: []}, fn(cell, %{board: next_board, changed_coords: changed_coords}) ->
      cond do
        cell.type == :general && TurnRules.tick_matches(turn, board.turn_rules, :general) -> Cell.tick_population(cell)
        cell.type == :town && TurnRules.tick_matches(turn, board.turn_rules, :town) && cell.owner != nil -> Cell.tick_population(cell)
        cell.type == :plains && TurnRules.tick_matches(turn, board.turn_rules, :plains) && cell.owner != nil && cell.population_count > 0 -> Cell.tick_population(cell)
        true -> nil
      end |> case do
        nil -> %{board: next_board, changed_coords: changed_coords}
        ticked_cell -> %{changed_coords: [Cell.coords(cell) | changed_coords], board: Board.replace_cell(next_board, Cell.coords(cell), ticked_cell)}
      end
    end)
  end

  def randomize_board(board = %Board{}, generation_stats, opts \\ []) do
    options = Keyword.merge([randomization_strategy: Board.BasicRandomization], opts)
    options[:randomization_strategy].randomize_board(board, generation_stats)
  end

  def at(board, {row, col}) do
    board.cells |> Enum.at(row) |> Enum.at(col)
  end

  def get_cells(board, type: type) do
    List.flatten(board.cells)
      |> Enum.filter(&(&1.type == type))
  end

  def special_type_coordinates(board) do
    List.flatten(board.cells)
      |> Enum.filter(&(&1.type != :plains))
      |> Enum.map(&({&1.row, &1.column}))
  end

  def get_player_visible_cells(board, player) do
    valid_coords = get_player_owned_coords(board, player) |> get_neighboring_coords(board)
    List.flatten(board.cells) |> Enum.filter(fn(%{row: row, column: column}) ->
      Enum.member?(valid_coords, {row, column})
    end)
  end

  def get_player_visible_cells(board, player, changed_coords) do
    player_visible_coords = get_player_owned_coords(board, player) |> get_neighboring_coords(board)
    visible_changed_coords = MapSet.intersection(Enum.into(changed_coords, MapSet.new), Enum.into(player_visible_coords, MapSet.new))

    List.flatten(board.cells) |> Enum.filter(fn(%{row: row, column: column}) ->
      Enum.member?(visible_changed_coords, {row, column})
    end)
  end

  def get_player_visible_neighbor_cells(board, player, source_coords) do
    selected_coords = get_player_owned_coords(board, player)
      |> Enum.filter(fn(coords) ->
        Enum.member?(source_coords, coords)
      end)
      |> get_neighboring_coords(board)
      |> Enum.reject(fn(coords) ->
        Enum.member?(source_coords, coords)
      end)

    List.flatten(board.cells) |> Enum.filter(fn(%{row: row, column: column}) ->
      Enum.member?(selected_coords, {row, column})
    end)
  end

  defp get_player_owned_coords(board, player) do
    List.flatten(board.cells)
      |> Enum.filter(&(&1.owner == player))
      |> Enum.map(&({&1.row, &1.column}))
  end

  defp get_neighboring_coords(coords, %{dimensions: dimensions}) do
    Enum.flat_map(coords, fn({row, column}) ->
      [
        {row, column}, {row+1, column}, {row-1, column}, {row, column+1}, {row, column-1},
        {row-1, column-1}, {row-1, column+1}, {row+1, column-1}, {row+1, column+1},
      ]
        |> Enum.filter(&(Dimensions.valid_coords?(dimensions, &1)))
    end)
      |> Enum.uniq
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
