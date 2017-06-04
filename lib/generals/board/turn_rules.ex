defmodule Generals.Board.TurnRules do
  defstruct town: 1, plains: 25

  def tick_matches(turn, rules, :general), do: tick_matches(turn, rules, :town)
  def tick_matches(turn, rules, field) do
    rem(turn, Map.get(rules, field)) == 0
  end
end
