defmodule SSHnakes.AI do
  @moduledoc """
  This is the worlds worst Snake AI
  """
  use GenServer

  alias __MODULE__
  alias SSHnakes.Game
  alias SSHnakes.Game.Player
  @thinkrate 1000

  # API
  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  # Implementation
  def init(_args) do
    SSHnakes.Game.spawn_player()
    send(self, :tick)
    {:ok, %{}}
  end

  def handle_info(:tick, state) do
    Process.send_after(self(), :tick, @thinkrate)
    Game.turn_player(self(), Player.random_direction)
    {:noreply, state}
  end
end