defmodule SSHnakes.Formatter do
  alias IO.ANSI

  def format_viewport(%{pellets: pellets, player: player}) do
    [ANSI.clear,
    format_pellets(pellets),
    format_player(player),
    ANSI.reset,
     ANSI.home]
  end

  def format_pellets(pellets) do
    for {x,y} <- pellets do
      [cursor(x,y), "o"]
    end
  end

  def format_player({x,y}) do
    [cursor(x,y), "X"]
  end

  defp cursor(column, line)
    when is_integer(line) and line >= 0 and is_integer(column) and column >= 0 do
    "\e[#{line};#{column}H"
  end
end