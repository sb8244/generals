defmodule Generals.Board.Command do
  defstruct coords: {nil,nil}, type: nil, player: nil

  alias Generals.Board

  def get_move_command(player: player, coords: coords = {_,_}, board: board = %Board{}) do
    case valid_move?(board, coords) do
      true -> %__MODULE__{coords: coords, type: :move, player: player}
      false -> get_move_command(player: nil, coords: nil, board: nil)
    end
  end
  def get_move_command(player: _, coords: _, board: _), do: {:error, "Invalid move coordinates"}

  defp valid_move?(board = %{dimensions: dimensions}, coords) do
    Board.Dimensions.valid_coords?(dimensions, coords) &&
    Board.Cell.moveable?(Board.at(board, coords))
  end
end
