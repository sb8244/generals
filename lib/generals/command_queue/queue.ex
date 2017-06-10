defmodule Generals.CommandQueue.Queue do
  @doc """
  Defines the Queue structure

  * :turns - A map of queues containing the commands for each turn. A player can have a single
             command in a given turn. The queue is stored with `hd` containing the next item.
  """
  defstruct turns: %{}

  alias Generals.CommandQueue.Command

  def for_turn(queue, turn) when is_integer(turn) do
    Map.get(queue.turns, turn, [])
  end

  def add(queue, turn, command = %Command{}) when is_integer(turn) do
    Map.put(queue, :turns, add_to_turns(queue, turn, command))
  end

  def clear_for_player(queue, player: player, from_turn: turn) when is_integer(turn) do
    new_turns = Enum.map(queue.turns, fn({iter_turn, turn_queue}) ->
      case iter_turn >= turn do
        true -> {iter_turn, Enum.reject(turn_queue, &(&1.player == player))}
        false -> {iter_turn, turn_queue}
      end
    end) |> Enum.into(%{})
    Map.put(queue, :turns, new_turns)
  end

  defp add_to_turns(queue, turn, command = %{player: player}) do
    current_turn_queue = for_turn(queue, turn)

    case queue_includes_player(current_turn_queue, player) do
      false -> Map.put(queue.turns, turn, current_turn_queue ++ [command])
      true -> add_to_turns(queue, turn + 1, command)
    end
  end

  defp queue_includes_player(turn_queue, player) do
    Enum.any?(turn_queue, &(&1.player == player))
  end
end
