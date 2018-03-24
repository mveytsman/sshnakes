defmodule SSHnakes.Player do
  alias __MODULE__, as: State
  alias SSHnakes.TTY
  alias SSHnakes.Formatter
  alias SSHnakes.Game

  use GenServer

  defstruct [:game, :tty_pid]

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

    send(self, :print_position)
    {:ok, %State{game: game, tty_pid: tty_pid}}
  end

  def handle_cast({:move, direction}, %State{game: game} = state) do
    state = %{state | game: Game.move_player(game, direction)}
    {:noreply, state}
  end

  def handle_info(:print_position, state) do
    size = TTY.get_size(state.tty_pid)
    viewport = Game.get_viewport(state.game, size)
    IO.write Formatter.format_game(viewport)
    Process.send_after(self, :print_position, 50)
    {:noreply, state}
  end

end
