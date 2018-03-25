defmodule SSHnakes.Game.Player do
  require Logger
  alias __MODULE__

  @directions [:up, :right, :down, :left]

  defstruct [:position, :direction]

  def new(position) do
    %Player{position: position, direction: random_direction}
  end

  def move(%Player{position: {x, y}, direction: direction} = player) do
    position = case direction do
      :up -> {x, y-1}
      :right -> {x+1, y}
      :down -> {x, y+1}
      :left -> {x-1, y}
      _ -> {x, y}
    end
    %{player | position: position}
  end

  def turn(player, direction) do
    if direction in @directions do
      %{player | direction: direction}
    else
      Logger.info("Don't know how to to turn to #{direction}")
      player
    end

  end

  defp random_direction do
    Enum.random(@directions)
  end
end
