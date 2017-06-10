defmodule Generals.Game.CommandQueueServer do
  alias Generals.CommandQueue.Command
  alias Generals.CommandQueue.Queue

  def start_link do
    Agent.start_link(fn -> %Queue{} end)
  end

  def commands_for_turn(pid, turn) do
    Agent.get(pid, fn(queue) ->
      Queue.for_turn(queue, turn)
    end, 1000)
  end

  def add_command(pid, turn, command = %Command{}) do
    Agent.get_and_update(pid, fn(queue) ->
      {:ok, Queue.add(queue, turn, command)}
    end, 1000)
  end

  def clear_player_commands(pid, turn, player: player) do
    Agent.get_and_update(pid, fn(queue) ->
      {:ok, Queue.clear_for_player(queue, player: player, from_turn: turn)}
    end, 1000)
  end
end
