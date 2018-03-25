defmodule SSHnakes.Client do
  use GenServer

  alias __MODULE__
  alias SSHnakes.Game
  alias SSHnakes.Formatter

  defstruct [:port]

  @framerate 100

  # API
  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  # Implementation
  def init(_args) do
    port = Port.open({:spawn, "tty_sl -c -e"}, [:binary, :eof])
    SSHnakes.Game.spawn_player
    send(self, :tick)
    {:ok, %Client{port: port}}
  end

  def handle_info({port, {:data, data}}, %Client{port: port} = state) do
    case translate(data) do
      :unknown -> nil
      direction -> Game.turn_player(direction)
    end
    {:noreply, state}
  end

  def handle_info(:tick, %Client{port: port} = state) do
    Game.get_viewport(get_size(port))
    |> Formatter.format_viewport
    |> IO.write
    Process.send_after(self, :tick, @framerate)
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

  defp get_size(port) do
    # `:io.columns` / `io.lines` doesn't work here because our TTY is captured by the port, so we have to use this
    # https://github.com/blackberry/Erlang-OTP/blob/master/lib/kernel/src/user_drv.erl#L451-L460
    # It's not well documented :)
    <<width::native-integer-size(32), height::native-integer-size(32)>> =  :erlang.port_control(port, 100, []) |> :binary.list_to_bin

   {width, height}
  end
end
