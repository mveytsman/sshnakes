defmodule SSHnakes.Player do
  require Logger
  use GenServer

  alias __MODULE__, as: State
  alias SSHnakes.TTY
  alias SSHnakes.Formatter

  defstruct [:x, :y, :board]

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
    x = 10
    y = 12
    {:ok, %State{x: x, y: y, board: %{{x,y} => "x"}}}
  end

  def handle_cast({:move, :up}, %State{y: y} = state) do
    {:noreply, %State{state | y: y - 1}}
  end

  def handle_cast({:move, :down}, %State{y: y} = state) do
    {:noreply, %State{state | y: y + 1}}
  end

  def handle_cast({:move, :left}, %State{x: x} = state) do
    {:noreply, %State{state | x: x - 1}}
  end

  def handle_cast({:move, :right}, %State{x: x} = state) do
    {:noreply, %State{state | x: x + 1}}
  end

  def handle_cast({:move, dir}, state) do
    Logger.info("Don't know how to move #{dir}")
    {:noreply, state}
  end

  def handle_info(:print_position, %State{x: x, y: y, board: board} = state) do
    IO.write Formatter.format_game(x, y)
    Process.send_after(self, :print_position, 50)
    {:noreply, state}
  end

end
