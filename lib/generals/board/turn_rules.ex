defmodule Generals.Board.TurnRules do
  @speedup_factor 3

  defstruct town: 1, plains: 25

  def speedup_factor, do: @speedup_factor
  def tick_matches(turn, rules, :general), do: tick_matches(turn, rules, :town)
  def tick_matches(turn, rules, field) do
    rem(turn, Map.get(rules, field) * @speedup_factor) == 0
  end
end
