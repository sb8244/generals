defmodule Generals.Game.TickServer do
  def start_link(opts = %{}) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts = %{ticker: ticker_fn}) do
    timeout = Map.get(opts, :timeout, 1000)
    schedule_tick(timeout)
    {:ok, %{ticker_fn: ticker_fn, timeout: timeout}}
  end

  def handle_info(:tick, state = %{ticker_fn: ticker_fn, timeout: timeout}) do
    schedule_tick(timeout)
    ticker_fn.()
    {:noreply, state}
  end

  defp schedule_tick(timeout) do
    Process.send_after(self(), :tick, timeout)
  end
end
