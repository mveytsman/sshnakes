defmodule SSHnakes.Client do
  use GenServer

  alias __MODULE__
  alias SSHnakes.Game
  alias SSHnakes.Formatter

  defstruct [:cli_pid, :width, :height]

  @framerate 130

  # API
  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def send_data(pid, data) do
    GenServer.cast(pid, {:data, data})
  end

  def resize(pid, width, height) do
    GenServer.cast(pid, {:resize, width, height})
  end

  # Implementation
  def init([cli_pid, width, height]) do
    SSHnakes.Game.spawn_player
    send(self, :tick)
    {:ok, %Client{cli_pid: cli_pid, width: width, height: height}}
  end

  def handle_cast({:data, data}, state) do
    case translate(data) do
      :unknown -> {:noreply, state}
      :spawn_ai ->
        Game.spawn_ai({0,0})
        {:noreply, state}
      :quit -> {:stop, :normal, state}
      direction ->
        Game.turn_player(self(), direction)
        {:noreply, state}
    end
  end

  def handle_cast({:resize, width, height}, state) do
    {:noreply, %{state | width: width, height: height}}
  end

  def handle_info(:tick, %Client{cli_pid: cli_pid, width: width, height: height} = state) do
    data = Game.get_viewport({width, height})
    |> Formatter.format_viewport()
    SSHnakes.SSH.Cli.send_data(cli_pid, data)
    Process.send_after(self, :tick, @framerate)
    {:noreply, state}
  end

  defp translate(keycode) do
    direction = case keycode do
      "\e[A" -> :up
      "\e[B" -> :down
      "\e[C" -> :right
      "\e[D" -> :left
      "x"    -> :spawn_ai
      "q"    -> :quit
      _ -> :unknown
    end
  end
end
