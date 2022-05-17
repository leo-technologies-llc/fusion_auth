defmodule FusionAuth.Application do
  use Application

  def start(_type, _args) do
    IO.inspect("==========================================")
    IO.inspect("==========================================")
    IO.inspect("==========================================")

    IO.inspect("==========================================")

    children = [
      FusionAuth.Repo
    ]

    opts = [strategy: :one_for_one, name: FusionAuth.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
