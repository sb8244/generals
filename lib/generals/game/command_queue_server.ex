defmodule Generals.Game.CommandQueueServer do
  alias Generals.CommandQueue.Command
  alias Generals.CommandQueue.Queue

  def start_link do
    Agent.start_link(fn -> %Queue{} end)
  end

  @doc """
    Return the commands for a given turn
  """
  def commands_for_turn(pid, turn) do
    Agent.get(pid, fn(queue) ->
      Queue.for_turn(queue, turn)
    end, 1000)
  end

  @doc """
    Add a Command to the end of the queue
  """
  def add_command(pid, turn, command = %Command{}) do
    Agent.get_and_update(pid, fn(queue) ->
      {:ok, Queue.add(queue, turn, command)}
    end, 1000)
  end

  @doc """
    Remove all commands from the provided turn
  """
  def clear_player_commands(pid, turn, player: player) do
    Agent.get_and_update(pid, fn(queue) ->
      {:ok, Queue.clear_for_player(queue, player: player, from_turn: turn)}
    end, 1000)
  end
end
