defmodule SSHnakes.Game do
  alias __MODULE__
  alias SSHnakes.Game.Impl
  alias SSHnakes.Game.Player
  use GenServer

  defstruct [:players, :pellets]

  @name __MODULE__
  @tickrate 125

  # API
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: @name)
  end

  def spawn_player() do
    GenServer.call(@name, :spawn_player)
  end

  def spawn_ai(pos) do
    {:ok, pid} = DynamicSupervisor.start_child(SSHnakes.AI.Supervisor, {SSHnakes.AI, []})
  end

  def turn_player(pid, direction) do
    GenServer.cast(@name, {:turn_player, pid, direction})
  end

  def get_game() do
    GenServer.call(@name, :get_game)
  end

  def get_viewport(size) do
    GenServer.call(@name, {:get_viewport, size})
  end

  # Implementation
  def init(_args) do
    game = Impl.new
    send(self, :tick)
    {:ok, game}
  end

  def handle_call(:spawn_player, {pid, _tag}, game) do
    {:reply, :ok, Impl.spawn_player(game, pid)}
  end

  def handle_cast({:turn_player, pid, direction}, %Game{players: players} = game) do
    players = Map.update!(players, pid, &Player.turn(&1, direction))
    {:noreply, %{game | players: players}}
  end

  def handle_call(:get_game, {pid, _tag}, game) do
    {:reply, game, game}
  end

  def handle_call({:get_viewport, size}, {pid, _tag}, game) do
    {:reply, Impl.get_viewport(game, pid, size), game}
  end

  def handle_info(:tick, game) do
    Process.send_after(self, :tick, @tickrate)
    {:noreply, Impl.do_tick(game)}
  end
end