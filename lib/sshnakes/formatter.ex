defmodule SSHnakes.Formatter do
  @moduledoc """
  Formats Games into IO Lists that can then be written to an interface
  """
  alias IO.ANSI
  alias SSHnakes.Game
  alias SSHnakes.Game.Player

  @doc """
  Formats a viewport.

  A viewport is a %Game{} struct with only the objects we can see it in it,
  their coordinates translated such that our player is at the center
  """
  def format_viewport(%Game{pellets: pellets, players: players}) do
    [ANSI.clear,
    format_pellets(pellets),
    format_players(players),
    ANSI.reset,
    ANSI.home]
  end

  def format_pellets(pellets) do
    for {{x,y}, _} <- pellets do
      [cursor(x,y), "x"]
    end
  end

  def format_player(%Player{position: position, tail: tail}) do
    head = case position do
      {x,y} -> [cursor(x,y), "@"]
      nil -> []
    end
    tail = for {x,y} <- tail do
      [cursor(x,y), "o"]
    end

    [head, tail]
  end

  def format_players(players) do
    players
    |> Map.values()
    |> Enum.map(&format_player/1)
  end

  defp cursor(column, line)
    when is_integer(line) and line >= 0 and is_integer(column) and column >= 0 do
    "\e[#{line};#{column}H"
  end
end