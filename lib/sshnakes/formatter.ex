defmodule SSHnakes.Formatter do
  alias IO.ANSI
  alias SSHnakes.Game
  alias SSHnakes.Game.Player

  def format_viewport(%Game{pellets: pellets, player: player}) do
    [ANSI.clear,
    format_pellets(pellets),
    format_player(player),
    ANSI.reset,
     ANSI.home]
  end

  def format_pellets(pellets) do
    for {{x,y}, _} <- pellets do
      [cursor(x,y), "x"]
    end
  end

  def format_player(%Player{position: {x,y}, tail: tail}) do
    head = [cursor(x,y), "@"]
    tail = for {x,y} <- tail do
      [cursor(x,y), "o"]
    end

    [head, tail]
  end

  defp cursor(column, line)
    when is_integer(line) and line >= 0 and is_integer(column) and column >= 0 do
    "\e[#{line};#{column}H"
  end
end