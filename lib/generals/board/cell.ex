defmodule Generals.Board.Cell do
  defstruct population_count: 0, owner: nil, type: :plains

  def make_general(cell, owner: owner) do
    Map.merge(cell, %{owner: owner, type: :general})
  end

  def make_mountain(cell) do
    Map.merge(cell, %{type: :mountain})
  end
end
