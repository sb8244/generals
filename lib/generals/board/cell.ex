defmodule Generals.Board.Cell do
  defstruct population_count: 0, owner: nil, type: :plains, row: nil, column: nil

  def make(:general, cell, owner: owner) do
    Map.merge(cell, %{owner: owner, type: :general})
  end

  def make(:mountain, cell) do
    Map.merge(cell, %{type: :mountain})
  end

  def make(:town, cell) do
    Map.merge(cell, %{type: :town, population_count: 15})
  end
end
