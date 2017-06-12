defmodule Generals.Board.GenerationStats do
  defstruct player_count: nil, town_percent_range: (0..0), mountain_percent_range: (0..0)

  def for_game(player_count: pc) do
    %__MODULE__{player_count: pc, town_percent_range: (2..5), mountain_percent_range: (8..18)}
  end
end
