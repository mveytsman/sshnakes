defmodule SSHnakes.Game do
  require Logger
  alias __MODULE__
  defstruct [:player, :pellets]
  @width 1000
  @height 1000

  def new do
    pellets = for i <- 0..10000 do
       random_point
    end
    player = random_point

    # Make sure the player doesn't start on a pellet
   # pellets = Enum.reject(&Kernel.==(&1, player))

    %Game{player: player, pellets: pellets}
  end

  def get_viewport(%Game{player: {player_x, player_y} , pellets: pellets}, {width, height}) do
    {origin_x, origin_y} = {player_x - div(width,2), player_y - div(height,2)}
    translated_pellets = pellets
    |> Stream.reject(fn {x,y} ->
      x < origin_x || x > origin_x + width ||
      y < origin_y || y > origin_y + height
    end)
    |> Stream.map(fn {x,y} ->
      {x - origin_x, y - origin_y}
    end)

    %Game{pellets: translated_pellets, player: {div(width,2), div(height,2)}}
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