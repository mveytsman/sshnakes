defmodule SSHnakes.Player do
  alias __MODULE__, as: State
  alias SSHnakes.TTY
  alias SSHnakes.Formatter
  alias SSHnakes.Game

  use GenServer

  defstruct [:game, :tty_pid, :direction]

  # API
  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def move(pid, direction) do
    GenServer.cast(pid, {:move, direction})
  end

  # Implementation

  def init(_args) do
    {:ok, tty_pid} = GenServer.start_link(TTY, self)
    game = Game.new
    direction = Enum.random([:up, :right, :down, :left])
    send(self, :tick)
    {:ok, %State{game: game, tty_pid: tty_pid, direction: direction}}
  end

  def handle_cast({:move, direction}, state) do
    case direction do
    direction
      when direction in [:up, :right, :down, :left]
      -> {:noreply, %{state | direction: direction}}
    _ ->   {:noreply, state}
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
