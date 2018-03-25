defmodule SSHnakes.Game.Impl do
  require Logger

  alias SSHnakes.Game
  alias SSHnakes.Game.Player

  @width 1000
  @height 1000
  def new do
    pellets = for _ <- 0..10000 do
       {random_point(), true}
    end |> Map.new
    player = Player.new(random_point())

    %Game{pellets: pellets, player: player}
  end

  def get_viewport(%Game{player: player, pellets: pellets} = game, {width, height} = size) do
    {player_x, player_y} = player.position
    origin = {player_x - div(width,2), player_y - div(height,2)}

    player = translate_player(player, origin, size)
    pellets = translate_pellets(pellets, origin, size)

    %Game{pellets: pellets, player: player}
  end

  def translate_pellets(pellets, origin, size) do
    for {pos, v} <- pellets, in_viewport?(pos, origin, size) do
      {translate(pos, origin), v}
    end |> Map.new
  end

  def translate_player(%Player{position: position, tail: tail} = player, origin, size) do
    position = translate(position, origin)
    tail = for pos <- tail, in_viewport?(pos, origin, size), do: translate(pos, origin)
    %{player | position: position, tail: tail}
  end

  def do_tick(game) do
    game
    |> move_player
  end

  def move_player(%Game{player: player, pellets: pellets} = game) do
    new_pos = Player.peek_move(player)
    case pellets[new_pos] do
      true -> %{game | player: Player.grow(player), pellets: Map.delete(pellets, new_pos)}
      _ -> %{game | player: Player.move(player)}
    end
  end

  defp random_point do
    {Enum.random(0..@width), Enum.random(0..@height)}
  end

  defp in_viewport?({x,y}, {origin_x, origin_y}, {width, height}) do
    x >= origin_x &&
    x <= origin_x + width &&
    y >= origin_y &&
    y <= origin_y + height
  end

  defp translate({x,y}, {origin_x, origin_y}) do
    {x - origin_x, y - origin_y}
  end
end