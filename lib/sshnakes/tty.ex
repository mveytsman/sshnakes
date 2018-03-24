defmodule SSHnakes.TTY do
  use GenServer

  alias __MODULE__, as: State
  alias SSHnakes.Player

  defstruct [:port, :player]

  # API
  def start_link(player_pid) do
    GenServer.start_link(__MODULE__, player_pid)
  end

  def get_size(pid) do
    GenServer.call(pid, :get_size)
  end

  # Implementation
  def init(player_pid) do
    port = Port.open({:spawn, "tty_sl -c -e"}, [:binary, :eof])
    {:ok, %State{port: port, player: player_pid}}
  end


  def handle_call(:get_size, _from, %State{port: port} = state) do
    # `:io.columns` / `io.lines` doesn't work here because our TTY is captured by the port, so we have to use this
    # https://github.com/blackberry/Erlang-OTP/blob/master/lib/kernel/src/user_drv.erl#L451-L460
    # It's not well documented :)
    <<width::native-integer-size(32), height::native-integer-size(32)>> =  :erlang.port_control(port, 100, []) |> :binary.list_to_bin

    {:reply, {width, height}, state}
  end


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
