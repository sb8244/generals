defmodule Generals.Board.BoardSerializerTest do
  use ExUnit.Case, async: true

  alias Generals.Board
  alias Generals.Board.BoardSerializer

  describe "for_player/2" do
    test "only the coords visible to this player are included in the output" do
      assert Board.get_new(rows: 3, columns: 3)
        |> Board.replace_cell({0, 0}, %Board.Cell{ row: 0, column: 0, owner: 0, type: :general, population_count: 10 })
        |> Board.replace_cell({0, 1}, %Board.Cell{ row: 0, column: 1, owner: 0, type: :town })
        |> BoardSerializer.for_player(player: 0) == %{
          rows: 3,
          columns: 3,
          cells: [
            %{ coords: %{row: 0, column: 0}, type: "general", owner: 0, population_count: 10 },
            %{ coords: %{row: 0, column: 1}, type: "town", owner: 0, population_count: 0 },
            %{ coords: %{row: 0, column: 2}, type: "plains", owner: nil, population_count: 0 },
            %{ coords: %{row: 1, column: 0}, type: "plains", owner: nil, population_count: 0 },
            %{ coords: %{row: 1, column: 1}, type: "plains", owner: nil, population_count: 0 },
          ],
          mountains: [],
        }
    end

    test "mountains are included in the output" do
      assert Board.get_new(rows: 3, columns: 3)
        |> Board.replace_cell({0, 0}, %Board.Cell{ row: 0, column: 0, type: :mountain })
        |> Board.replace_cell({0, 1}, %Board.Cell{ row: 0, column: 1, type: :mountain })
        |> BoardSerializer.for_player(player: 0) == %{
          rows: 3,
          columns: 3,
          cells: [],
          mountains: [
            %{ coords: %{row: 0, column: 0}, type: "mountain", owner: nil, population_count: 0 },
            %{ coords: %{row: 0, column: 1}, type: "mountain", owner: nil, population_count: 0 },
          ]
        }
    end

    test "cells aren't duplicated" do
      assert Board.get_new(rows: 1, columns: 2)
        |> Board.replace_cell({0, 0}, %Board.Cell{ row: 0, column: 0, type: :mountain })
        |> Board.replace_cell({0, 1}, %Board.Cell{ row: 0, column: 1, owner: 0 })
        |> BoardSerializer.for_player(player: 0) == %{
          rows: 1,
          columns: 2,
          cells: [
            %{ coords: %{row: 0, column: 1}, type: "plains", owner: 0, population_count: 0 },
          ],
          mountains: [
            %{ coords: %{row: 0, column: 0}, type: "mountain", owner: nil, population_count: 0 },
          ]
        }
    end
  end
end
