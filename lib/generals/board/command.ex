defmodule Generals.Board.Command do
  defstruct from: {nil, nil}, to: {nil,nil}, type: nil, player: nil

  alias Generals.Board

  def get_move_command(player: player, from: from = {_,_}, to: coords = {_,_}, board: board = %Board{}) do
    case valid_move?(board, from, coords) do
      true -> %__MODULE__{from: from, to: coords, type: :move, player: player}
      false -> get_move_command(player: nil, from: nil, to: nil, board: nil)
    end
  end
  def get_move_command(player: _, from: _, to: _, board: _), do: {:error, "Invalid move coordinates"}

  defp valid_move?(board = %{dimensions: dimensions}, from, to) do
    Board.Dimensions.valid_coords?(dimensions, to) &&
    Board.Dimensions.valid_coords?(dimensions, from) &&
    Board.Cell.moveable?(Board.at(board, to)) &&
    manhatten_distance(from, to) == 1
  end

  defp manhatten_distance({r,c}, {r2,c2}) do
    abs(r - r2) + abs(c - c2)
  end
end
