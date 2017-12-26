defmodule Generals.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Generals.Web.Endpoint, []),
      supervisor(Registry, [:unique, Generals.Game.Supervisor.get_registry_name]),
      supervisor(Generals.GamesSupervisor, []),
    ]

    if System.get_env("OBSERVE"), do: :observer.start

    opts = [strategy: :one_for_one, name: Generals.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
