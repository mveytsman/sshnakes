defmodule SSHnakes.SSH.Supervisor do
  use Supervisor

  @name __MODULE__

  def start_link(_args) do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def init(:ok) do
    children = [
      {SSHnakes.SSH.Daemon, []},
      {DynamicSupervisor, name: SSHnakes.SSH.Session.Supervisor, strategy: :one_for_one}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
