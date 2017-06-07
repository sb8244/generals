defmodule Generals.Board.Command do
  defstruct from: {nil, nil}, to: {nil,nil}, type: nil, player: nil

  alias Generals.Board

  def get_move_command(player: player, from: from = {_,_}, to: coords = {_,_}, board: board = %Board{}) do
    case validate_move(board, from, coords, player) do
      true -> %__MODULE__{from: from, to: coords, type: :move, player: player}
      {:error, _} = error -> error
    end
  end
  def get_move_command(player: _, from: _, to: _, board: _), do: {:error, "Cannot move to this space"}

  defp validate_move(board = %{dimensions: dimensions}, from, to, player) do
    valid_movement = Board.Dimensions.valid_coords?(dimensions, to) &&
                     Board.Dimensions.valid_coords?(dimensions, from) &&
                     Board.Cell.moveable?(Board.at(board, to)) &&
                     manhatten_distance(from, to) == 1

    case valid_movement do
      false -> {:error, "Cannot move to this space"}
      true ->
        valid_ownership = Board.Cell.owned_by?(Board.at(board, from), player)
        case valid_ownership do
          false -> {:error, "Cannot move from a space you don't hold"}
          true -> true
        end
    end
  end

  defp manhatten_distance({r,c}, {r2,c2}) do
    abs(r - r2) + abs(c - c2)
  end
end
