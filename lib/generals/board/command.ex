defmodule Generals.Board.Command do
  defstruct coords: {nil,nil}, type: nil, player: nil

  alias Generals.Board

  def get_move_command(player: player, coords: coords = {_,_}, dimensions: dimensions) do
    case Board.Dimensions.valid_coords?(dimensions, coords) do
      true -> %__MODULE__{coords: coords, type: :move, player: player}
      false -> get_move_command(player: nil, coords: nil, dimensions: nil)
    end
  end
  def get_move_command(player: _, coords: _, dimensions: _), do: {:error, "Invalid move coordinates"}
end
