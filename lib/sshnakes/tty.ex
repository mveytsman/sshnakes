defmodule SSHnakes.TTY do
  use GenServer

  alias __MODULE__, as: State
  alias SSHnakes.Player

  defstruct [:port, :player]

  def start_link(player_pid) do
    GenServer.start_link(__MODULE__, player_pid)
  end

  def init(player_pid) do
    port = Port.open({:spawn, "tty_sl -c -e"}, [:binary, :eof])
    {:ok, %State{port: port, player: player_pid}}
  end

  # def handle_call(:get_width, from, state) do
  #   {:reply, Impl.get_width(), state}
  # end


  # def handle_call(:get_height, from, state) do
  #   {:reply, Impl.get_height(), state}
  # end

  def handle_info({port, {:data, data}}, %State{port: port, player: player} = state) do
    case translate(data) do
      :unknown -> nil
      direction -> Player.move(player, direction)
    end
    {:noreply, state}
  end

  defp translate(keycode) do
    direction = case keycode do
      "\e[A" -> :up
      "\e[B" -> :down
      "\e[C" -> :right
      "\e[D" -> :left
      _ -> :unknown
    end
  end
end
