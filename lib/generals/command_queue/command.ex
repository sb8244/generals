defmodule Generals.CommandQueue.Command do
  defstruct from: {nil, nil}, to: {nil,nil}, type: nil, player: nil

  alias Generals.Board

  @invalid_ownership_error "Cannot move from a space you don't hold"
  @invalid_move_error      "Cannot move to this space"

  def get_move_command(player: player, from: from = {_,_}, to: coords = {_,_}, board: board = %Board{}) do
    case validate_move(board, from, coords) do
      true -> %__MODULE__{from: from, to: coords, type: :move, player: player}
      {:error, _} = error -> error
    end
  end
  def get_move_command(player: _, from: _, to: _, board: _), do: {:error, "Cannot move to this space"}

  def execute(command = %__MODULE__{player: player, from: from}, board = %Board{}) do
    case Board.Cell.owned_by?(Board.at(board, from), player) do
      false -> {:error, @invalid_ownership_error}
      true -> {:ok, perform_move(command, board)}
    end
  end

  defp validate_move(board = %{dimensions: dimensions}, from, to) do
    valid_movement = Board.Dimensions.valid_coords?(dimensions, to) &&
                     Board.Dimensions.valid_coords?(dimensions, from) &&
                     Board.Cell.moveable?(Board.at(board, to)) &&
                     manhatten_distance(from, to) == 1

    case valid_movement do
      false -> {:error, @invalid_move_error}
      true -> true
    end
  end

  defp perform_move(%__MODULE__{ from: from, to: to }, board) do
    from_cell = Board.at(board, from)
    to_cell = Board.at(board, to)

    case compute_move(from_cell.owner == to_cell.owner, from_armies: from_cell.population_count - 1, to_armies: to_cell.population_count) do
      {:from, new_to_population} ->
        board
          |> Board.replace_cell(from, Map.merge(from_cell, %{ population_count: 1 }))
          |> Board.replace_cell(to, Map.merge(to_cell, %{ population_count: new_to_population, owner: from_cell.owner }))
          |> convert_general(to_cell.type, to_coords: to, from_owner: to_cell.owner, to_owner: from_cell.owner)
      {:to, new_to_population} ->
        board
          |> Board.replace_cell(from, Map.merge(from_cell, %{ population_count: 1 }))
          |> Board.replace_cell(to, Map.merge(to_cell, %{ population_count: new_to_population }))
      {:noop} ->
        board
    end
  end

  defp compute_move(true, from_armies: from_armies, to_armies: to_armies)
    when from_armies > 0,
    do: {:from, from_armies + to_armies}
  defp compute_move(false, from_armies: from_armies, to_armies: to_armies)
    when from_armies > 0 and from_armies > to_armies,
    do: {:from, from_armies - to_armies}
  defp compute_move(false, from_armies: from_armies, to_armies: to_armies)
    when from_armies > 0 and to_armies > from_armies,
    do: {:to, to_armies - from_armies}
  defp compute_move(false, from_armies: from_armies, to_armies: to_armies)
    when from_armies > 0 and to_armies == from_armies,
    do: {:to, 0}
  defp compute_move(_, from_armies: from_armies, to_armies: _)
    when from_armies <= 0,
    do: {:noop}

  defp convert_general(board, :general, to_coords: to_coords, from_owner: from, to_owner: to) do
    to_cell = Board.at(board, to_coords)
    board
      |> Board.replace_cell(to_coords, Map.merge(to_cell, %{ type: :town }))
      |> Board.convert_owner_on_all_owned_cells(from: from, to: to)
  end
  defp convert_general(board, _, _), do: board

  defp manhatten_distance({r,c}, {r2,c2}) do
    abs(r - r2) + abs(c - c2)
  end
end
