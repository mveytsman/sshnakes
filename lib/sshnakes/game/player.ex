defmodule SSHnakes.Game.Player do
  require Logger
  alias __MODULE__

  @directions [:up, :right, :down, :left]

  defstruct [:position, :direction, :tail]

  def new(position, direction \\ random_direction(), tail \\ []) do
    %Player{position: position, direction: direction, tail: tail}
  end

  def turn(player, direction) do
    if direction in @directions do
      %{player | direction: direction}
    else
      Logger.info("Don't know how to to turn to #{direction}")
      player
    end
  end

  def peek_move(%Player{position: {x,y}, direction: direction}) do
    case direction do
      :up -> {x, y-1}
      :right -> {x+1, y}
      :down -> {x, y+1}
      :left -> {x-1, y}
    end
  end

  def move(%Player{position: pos, direction: direction, tail: tail} = player) do
    new_pos = peek_move(player)
    %{player | position: new_pos, tail: Enum.drop([pos | tail], -1)}
  end

  def grow(%Player{position: pos, direction: direction, tail: tail} = player) do
    new_pos = peek_move(player)
    %{player | position: new_pos, tail: [pos | tail]}
  end

  def random_direction do
    Enum.random(@directions)
  end
end
