defmodule Generals.Board.Dimensions do
  defstruct rows: 0, columns: 0

  def valid_coords?(%__MODULE__{rows: rows, columns: columns}, {r,c}) do
    r >= 0 && c >= 0 &&
    r < rows && c < columns
  end

  def size(dimensions) do
    dimensions.rows * dimensions.columns
  end

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
