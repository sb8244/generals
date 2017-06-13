defmodule Generals.Game.TickServer do
  def start_link(opts = %{}) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(%{ticker: ticker_fn, timeout: timeout}) do
    schedule_tick(5000)
    {:ok, %{ticker_fn: ticker_fn, timeout: timeout, ticking: false}}
  end

  def ticking?(pid) do
    GenServer.call(pid, :ticking?)
  end

  def handle_info(:start_tick, state) do
    send self(), :tick
    {:noreply, Map.put(state, :ticking, true)}
  end

  def handle_info(:tick, state = %{ticker_fn: ticker_fn, timeout: timeout}) do
    schedule_tick(timeout)
    ticker_fn.()
    {:noreply, Map.put(state, :ticking, false)}
  end

  def handle_call(:ticking?, _from, state = %{ticking: ticking}) do
    {:reply, ticking, state}
  end

  defp schedule_tick(timeout) do
    Process.send_after(self(), :start_tick, timeout)
  end
end
