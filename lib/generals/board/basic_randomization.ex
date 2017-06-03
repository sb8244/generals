defmodule Generals.Board.BasicRandomization do
  alias Generals.Board
  alias Generals.Board.Cell
  alias Generals.Board.Dimensions
  alias Generals.Board.GenerationStats

  def randomize_board(board, generation_stats) do
    board
      |> randomize_player_generals(generation_stats)
      |> randomize_mountains(generation_stats)
      |> randomize_towns(generation_stats)
  end

  defp randomize_player_generals(board, %GenerationStats{ player_count: player_count }) do
    Enum.reduce(1..player_count, {board, []}, fn(player_id, {board, placed_general_coords}) ->
      coords = Dimensions.random_coordinates(board.dimensions, exclude: placed_general_coords)
      existing_cell = Board.at(board, coords)
      new_cell = Cell.make(:general, existing_cell, owner: player_id)
      {
        Board.replace_cell(board, coords, new_cell),
        [coords | placed_general_coords]
      }
    end) |> elem(0)
  end

  defp randomize_mountains(board, %GenerationStats{ mountain_percent_range: range }) do
    count = get_random_count_in_range(board, range)
    convert_random_empty_cells_to_type(board, count, :mountain)
  end

  defp randomize_towns(board, %GenerationStats{ town_percent_range: range }) do
    count = get_random_count_in_range(board, range)
    convert_random_empty_cells_to_type(board, count, :town)
  end

  defp get_random_count_in_range(%Board{dimensions: dimensions}, (min..max)) do
    minimum = Dimensions.size(dimensions) * (min/100) |> Float.floor |> trunc
    maximum = Dimensions.size(dimensions) * (max/100) |> Float.ceil |> trunc
    Enum.random(minimum..maximum)
  end

  defp convert_random_empty_cells_to_type(board, count, type) do
    cond do
      count > 0 ->
        Enum.reduce(1..count, {board, []}, fn(_, {board, placed_coords}) ->
          coords = Dimensions.random_coordinates(board.dimensions, exclude: placed_coords)
          existing_cell = Board.at(board, coords)
          new_cell = Cell.make(type, existing_cell)
          {
            Board.replace_cell(board, coords, new_cell),
            [coords | placed_coords]
          }
        end) |> elem(0)
      count == 0 -> board
    end
  end
end
