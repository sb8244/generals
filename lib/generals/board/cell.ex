defmodule Generals.Board.Cell do
  defstruct population_count: 0, owner: nil, type: :plains, row: nil, column: nil

  def coords(cell) do
    {cell.row, cell.column}
  end

  def moveable?(cell) do
    cell.type != :mountain
  end

  def owned_by?(cell, owner) do
    cell.owner == owner
  end

  def make(:general, cell, owner: owner) do
    Map.merge(cell, %{owner: owner, type: :general})
  end

  def make(:mountain, cell) do
    Map.merge(cell, %{type: :mountain})
  end

  def make(:town, cell) do
    Map.merge(cell, %{type: :town, population_count: 15})
  end

  def tick_population(cell) do
    Map.merge(cell, %{population_count: cell.population_count + 1})
  end
end
