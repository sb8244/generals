defmodule Generals.Game.TickServerTest do
  use ExUnit.Case, async: true

  alias Generals.Game.TickServer

  test "the ticker fn is called every timeout" do
    this = self()
    ticker = fn() ->
      send this, :tick
    end

    {:ok, _pid} = TickServer.start_link(%{ticker: ticker, timeout: 10})
    assert_receive :tick, 15
    assert_receive :tick, 15
  end
end
