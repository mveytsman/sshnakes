defmodule SSHnakes.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: SSHnakes.Worker.start_link(arg)
      # {SSHnakes.Worker, arg},
      {SSHnakes.Game, []},
      #{SSHnakes.Client, []},
      {DynamicSupervisor, name: SSHnakes.AI.Supervisor, strategy: :one_for_one},
      {SSHnakes.SSH.Supervisor, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SSHnakes.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
