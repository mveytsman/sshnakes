defmodule SSHnakes.SSH.Daemon do
  @key_dir File.cwd! |> Path.join("priv/ssh_dir") |> String.to_charlist #this *has* to be a charlist because erlang

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link(_args) do
    port = Application.get_env(:sshnakes, :ssh_port)
    :ssh.daemon(port,
      system_dir: @key_dir,
      key_cb: SSHnakes.SSH.NopAuth,
      pwdfun: &SSHnakes.SSH.NopAuth.is_valid_password/4,
      ssh_cli:  {SSHnakes.SSH.Cli, []},
      #shell: &SSHnakes.SSH.Session.start_session(&1,&2),
      #exec: &nop_exec/3,
      subsystems: [],
      parallel_login: true,
      max_sessions: 100000, # how many can I take?
    )
  end

  def nop_exec(_cmd,_username,_peer) do
    spawn fn -> true end
  end
end
