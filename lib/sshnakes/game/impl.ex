defmodule SSHnakes.Game.Impl do
  require Logger

  alias SSHnakes.Game
  alias SSHnakes.Game.Player

  @width 100
  @height 100
  def new(pellet_coords \\ random_points(1000)) do
    pellets = make_pellets(pellet_coords)
    %Game{pellets: pellets, players: %{}}
  end

  def spawn_player(%Game{players: players} = game, pid, player_pos \\ random_point(), player_direction \\ Player.random_direction(), player_tail \\ []) do
    player = Player.new(player_pos, player_direction, player_tail)
    %{game | players: Map.put(players, pid, player)}
  end

  def get_viewport(%Game{players: players, pellets: pellets} = game, pid, {width, height} = size) do
    player = players[pid]
    {player_x, player_y} = player.position
    origin = {player_x - div(width, 2), player_y - div(height, 2)}

    players = for {key, player} <- players do
      {key, translate_player(player, origin, size)}
    end |> Map.new
    pellets = translate_pellets(pellets, origin, size)

    %Game{pellets: pellets, players: players}
  end

  def translate_pellets(pellets, origin, size) do
    for {pos, v} <- pellets, in_viewport?(pos, origin, size) do
      {translate(pos, origin), v}
    end
    |> Map.new()
  end

  def translate_player(%Player{position: position, tail: tail} = player, origin, size) do
    position = case in_viewport?(position, origin, size) do
      true -> translate(position, origin)
      false -> nil
    end
    tail = for pos <- tail, in_viewport?(pos, origin, size), do: translate(pos, origin)
    %{player | position: position, tail: tail}
  end

  def do_tick(game) do
    game
    |> move_players
    |> detect_collisions
  end

  def move_players(%Game{players: players, pellets: pellets} = game) do
    {players, pellets} = Enum.reduce(players, {%{}, pellets}, &do_move_players/2)
    %{game | players: players, pellets: pellets}
  end

  def detect_collisions(%Game{players: players, pellets: pellets} = game) do
    {players, pellets, _} = Enum.reduce(players, {%{}, pellets, players}, &do_detect_collisions/2)
    %{game | players: players, pellets: pellets}
  end

  def make_pellets(pellet_coords), do: Map.new(pellet_coords, fn pos -> {pos, true} end)
  def add_pellets(pellets, pellet_coords), do: Map.merge(pellets, make_pellets(pellet_coords))

  defp random_point do
    {Enum.random(0..@width), Enum.random(0..@height)}
  end

  defp random_points(count) do
    for _ <- 0..count do
      random_point()
    end
  end

  defp in_viewport?({x, y}, {origin_x, origin_y}, {width, height}) do
    x >= origin_x && x <= origin_x + width && y >= origin_y && y <= origin_y + height
  end

  defp translate({x, y}, {origin_x, origin_y}) do
    {x - origin_x, y - origin_y}
  end

  defp do_move_players({pid, player}, {players, pellets}) do
    new_pos = Player.peek_move(player)
    case pellets[new_pos] do
      true ->
        {Map.put(players, pid, Player.grow(player)), Map.delete(pellets, new_pos)}
      _ ->
        {Map.put(players, pid, Player.move(player)), pellets}
    end
  end

  defp do_detect_collisions({pid, player}, {new_players, pellets, old_players}) do
    others = Map.delete(old_players, pid)
    case Enum.find(others, fn {pid, other} -> players_collided?(player, other) end) do
      nil ->  {Map.put(new_players, pid, player), pellets, old_players}
      _ ->
        pellets = add_pellets(pellets, [player.position | player.tail])
        {Map.put(new_players, pid, Player.kill(player)), pellets, old_players}
    end
  end

  defp players_collided?(player1, player2) do
    #check if player1 collided with player2
    player1.position == player2.position or player1.position in player2.tail
  end
end
