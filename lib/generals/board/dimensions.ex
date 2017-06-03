defmodule Generals.Board.Dimensions do
  defstruct rows: 0, columns: 0

  def random_coordinates(dimensions, exclude: excluded_coords) do
    r_rand = :rand.uniform(dimensions.rows) - 1
    c_rand = :rand.uniform(dimensions.columns) - 1
    coords = {r_rand, c_rand}

    case Enum.member?(excluded_coords, coords) do
      true ->
        random_coordinates(dimensions, exclude: excluded_coords)
      false ->
        coords
    end
  end
end
