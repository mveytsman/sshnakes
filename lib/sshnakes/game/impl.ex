defmodule SSHnakes.Game.Impl do
  require Logger

  alias SSHnakes.Game
  alias SSHnakes.Game.Player

  @width 1000
  @height 1000
  def new do
    pellets = for _ <- 0..10000 do
       random_point
    end
    player = Player.new(random_point)
    %Game{pellets: pellets, player: player}
  end

  def get_viewport(%Game{player: player, pellets: pellets}, {width, height}) do
    {player_x, player_y} = player.position
    {origin_x, origin_y} = {player_x - div(width,2), player_y - div(height,2)}
    translated_pellets = pellets
    |> Stream.reject(fn {x,y} ->
      x < origin_x || x > origin_x + width ||
      y < origin_y || y > origin_y + height
    end)
    |> Stream.map(fn {x,y} ->
      {x - origin_x, y - origin_y}
    end)

    translated_player = %{player | position: {div(width,2), div(height,2)}}

    %Game{pellets: translated_pellets, player: translated_player}
  end

  def do_tick(game) do
    game
    |> move_player
  end

  def move_player(%Game{player: player} = game) do
    %{game | player: Player.move(player)}
  end

  defp random_point do
    {Enum.random(0..@width), Enum.random(0..@height)}
  end
end