defmodule Generals.Game.TickServerTest do
  use ExUnit.Case, async: true

  alias Generals.Game.TickServer

  test "the first tick doesn't happen in the timeout" do
    this = self()
    ticker = fn() ->
      send this, :tick
    end

    {:ok, _pid} = TickServer.start_link(%{ticker: ticker, timeout: 10})
    refute_receive :tick, 30
  end

  test "the ticker fn is called every timeout, and immediately with immediate_start=true" do
    this = self()
    ticker = fn() ->
      send this, :tick
    end

    {:ok, _pid} = TickServer.start_link(%{ticker: ticker, timeout: 10, immediate_start: true})
    assert_receive :tick, 15
    assert_receive :tick, 15
  end
end
