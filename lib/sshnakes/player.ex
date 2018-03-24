defmodule SSHnakes.Player do
  use GenServer
  alias SSHnakes.TTY
  alias SSHnakes.Formatter
  alias SSHnakes.Game

  # API
  def start_link(args) do
    {:ok, pid} = GenServer.start_link(__MODULE__, args)
    GenServer.start_link(TTY, pid)
    send(pid, :print_position)
    {:ok, pid}
  end

  def move(pid, direction) do
    GenServer.cast(pid, {:move, direction})
  end

  # Implementation

  def init(_args) do
    game = Game.new
    {:ok, game}
  end

  def handle_cast({:move, direction}, game) do
    {:noreply, Game.move_player(game, direction)}
  end

  def handle_info(:print_position, game) do
    IO.write Formatter.format_game(game)
    Process.send_after(self, :print_position, 50)
    {:noreply, game}
  end

end
