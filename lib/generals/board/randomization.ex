defmodule Generals.Board.Randomization do
  alias Generals.Board
  alias Generals.Board.Cell
  alias Generals.Board.Dimensions
  alias Generals.Board.GenerationStats

  def randomize_board(board, generation_stats) do
    board
      |> randomize_player_generals(generation_stats)
      |> randomize_mountains(generation_stats)
  end

  defp randomize_player_generals(board, %GenerationStats{ player_count: player_count }) do
    Enum.reduce(1..player_count, {board, []}, fn(player_id, {board, placed_general_coords}) ->
      coords = Dimensions.random_coordinates(board.dimensions, exclude: placed_general_coords)
      existing_cell = Board.at(board, coords)
      new_cell = Cell.make_general(existing_cell, owner: player_id)
      {
        Board.replace_cell(board, coords, new_cell),
        [coords | placed_general_coords]
      }
    end) |> elem(0)
  end

  def randomize_mountains(board, %GenerationStats{ mountain_percent_range: (mountain_percent_min..mountain_percent_max) }) do
    minimum_mountains = Dimensions.size(board.dimensions) * (mountain_percent_min/100) |> Float.floor |> trunc
    maximum_mountains = Dimensions.size(board.dimensions) * (mountain_percent_max/100) |> Float.ceil |> trunc
    mountain_count = Enum.random((minimum_mountains..maximum_mountains))

    cond do
      mountain_count > 0 ->
        Enum.reduce(1..mountain_count, {board, []}, fn(_, {board, placed_mountain_coords}) ->
          coords = Dimensions.random_coordinates(board.dimensions, exclude: placed_mountain_coords)
          existing_cell = Board.at(board, coords)
          new_cell = Cell.make_mountain(existing_cell)
          {
            Board.replace_cell(board, coords, new_cell),
            [coords | placed_mountain_coords]
          }
        end) |> elem(0)
      mountain_count == 0 -> board
    end
  end
end
