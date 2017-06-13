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
            %{ coords: {0,0}, type: "general", owner: 0, population_count: 10 },
            %{ coords: {0,1}, type: "town", owner: 0, population_count: 0 },
            %{ coords: {0,2}, type: "plains", owner: nil, population_count: 0 },
            %{ coords: {1,0}, type: "plains", owner: nil, population_count: 0 },
            %{ coords: {1,1}, type: "plains", owner: nil, population_count: 0 },
          ]
        }
    end
  end
end
