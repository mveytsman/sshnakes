defmodule SSHnakes.Game.Player do
  require Logger
  alias SSHnakes.TTY
  alias SSHnakes.Formatter
  alias SSHnakes.Game
  alias __MODULE__

  use GenServer

  @directions [:up, :right, :down, :left]

  defstruct [:position, :direction]

  def new(position) do
    %Player{position: position, direction: random_direction}
  end

  def move(%Player{position: {x, y}, direction: direction} = player) do
    position = case direction do
      :up -> {x, y-1}
      :right -> {x+1, y}
      :down -> {x, y+1}
      :left -> {x-1, y}
      _ -> {x, y}
    end
    %{player | position: position}
  end

  def turn(player, direction) do
    if direction in @directions do
      %{player | direction: direction}
    else
      Logger.info("Don't know how to to turn to #{direction}")
      player
    end

  end

  defp random_direction do
    Enum.random(@directions)
  end

  # Implementation

  def init(_args) do
    {:ok, tty_pid} = GenServer.start_link(TTY, self)
    player = %{SSHnakes.Game.spawn_player| tty_pid: tty_pid}
    send(self, :tick)
    {:ok, player}
  end

  def handle_cast({:move, direction}, state) do
    case direction do
    direction
      when direction in [:up, :right, :down, :left]
      -> {:noreply, %{state | direction: direction}}
    _ -> {:noreply, state}
    end
  end

  def handle_info(:tick, state) do
    size = TTY.get_size(state.tty_pid)
    viewport = Game.get_viewport(state.game, size)
    IO.write Formatter.format_game(viewport)
    Process.send_after(self, :tick, 50)
    {:noreply, %{state | game: Game.move_player(state.game, state.direction)}}
  end

end
