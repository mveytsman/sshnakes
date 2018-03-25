defmodule SSHnakes.Game do
  alias __MODULE__
  alias SSHnakes.Game.Impl
  alias SSHnakes.Game.Player
  use GenServer

  defstruct [:player, :pellets]

  @name __MODULE__
  @tickrate 100

  # API
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: @name)
  end

  def turn_player(direction) do
    GenServer.cast(@name, {:turn_player, direction})
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

  def handle_cast({:turn_player, direction}, %Game{player: player} = game) do
    player = Player.turn(player, direction)
    {:noreply, %{game | player: player}}
  end

  def handle_call({:get_viewport, size}, _from, game) do
    {:reply, Impl.get_viewport(game, size), game}
  end

  def handle_info(:tick, game) do
    Process.send_after(self, :tick, @tickrate)
    {:noreply, Impl.do_tick(game)}
  end
end