defmodule SSHnakes.Game do
  require Logger
  alias __MODULE__
  defstruct [:player, :pellets]
  @width 50
  @height 50

  def new do
    pellets = for i <- 0..20 do
       random_point
    end
    player = random_point

    # Make sure the player doesn't start on a pellet
   # pellets = Enum.reject(&Kernel.==(&1, player))

    %Game{player: player, pellets: pellets}
  end

  def move_player(%Game{player: {x, y}} = game, :up) do
    %Game{game | player: {x, y-1}}
  end

  def move_player(%Game{player: {x, y}} = game, :right) do
    %Game{game | player: {x+1, y}}
  end

  def move_player(%Game{player: {x, y}} = game, :down) do
    %Game{game | player: {x, y+1}}
  end

  def move_player(%Game{player: {x, y}} = game, :left) do
    %Game{game | player: {x-1, y}}
  end

  def handle_cast(game, direction) do
    Logger.info("Don't know how to move #{direction}")
    game
  end

  defp random_point do
    {Enum.random(0..@width), Enum.random(0..@height)}
  end
end