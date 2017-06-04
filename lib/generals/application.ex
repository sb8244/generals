defmodule Generals.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Registry, [:unique, Generals.GameSupervisor.get_registry_name]),
      supervisor(Generals.GamesSupervisor, []),
    ]

    opts = [strategy: :one_for_one, name: Generals.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
