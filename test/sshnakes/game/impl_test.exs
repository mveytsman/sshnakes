defmodule SSHnakes.Game.ImplTest do
  use ExUnit.Case, async: true

  import SSHnakes.Game.Impl
  alias SSHnakes.Game
  alias SSHnakes.Game.Player

  test "new/0" do
    game = new()
    assert game.players == %{}
    # We actually make 10000 random pellets, but we're not checking for duplicates so I can't test that the count is 10000
    assert Enum.count(game.pellets) > 0

  end

  test "new/1" do
    game = new([{1,2}, {3,4}])
    assert game.players == %{}
    assert Enum.count(game.pellets) == 2
    assert game.pellets[{1,2}] == true
    assert game.pellets[{3,4}] == true
  end

  test "spawn_player/2" do
    game = new()
    |> spawn_player(self())

    assert Enum.count(game.players) == 1
    assert %Player{} = game.players[self()]
  end

  test "spawn_player/3" do
    game = new()
    |> spawn_player(self(), {8,9})

    assert Enum.count(game.players) == 1
    assert %Player{position: {8,9}} = game.players[self()]
  end

  test "spawn_player/4" do
    game = new()
    |> spawn_player(self(), {8,9}, :up)

    assert Enum.count(game.players) == 1
    assert %Player{position: {8,9}, direction: :up} = game.players[self()]
  end

  test "spawn_player/5" do
    game = new()
    |> spawn_player(self(), {8,9}, :up, [{8,8}])

    assert Enum.count(game.players) == 1
    assert %Player{position: {8,9}, direction: :up, tail: [{8,8}]} = game.players[self()]
  end

  test "translate_pellets/3" do
    pellets = make_pellets([{1,1}, {2,2}, {3,3}, {4,4}, {5,5}])
    assert Map.keys(translate_pellets(pellets, {-1,-1}, {10,10})) == [{2, 2}, {3, 3}, {4, 4}, {5, 5}, {6, 6}]
    assert Map.keys(translate_pellets(pellets, {1,1}, {2,2})) == [{0, 0}, {1, 1}, {2, 2}]
  end

  test "translate_player/3" do
    player = Player.new({15,10}, :left)
    |> Player.grow
    |> Player.grow
    |> Player.grow
    |> Player.grow
    |> Player.grow

    # We moved the player as we grew it so it's at {10,10} now
    assert player.position == {10,10}
    assert player.tail == [{11, 10}, {12, 10}, {13, 10}, {14, 10}, {15, 10}]

    translated_player = translate_player(player, {5,5}, {10,10})
    assert translated_player.position == {5,5}
    assert translated_player.tail == [{6, 5}, {7, 5}, {8, 5}, {9, 5}, {10, 5}]

    # If the tail is longer than the viewport size we have to cut it off
    translated_player = translate_player(player, {9,9}, {3,3})
    assert translated_player.position == {1,1}
    assert translated_player.tail == [{2, 1}, {3, 1}]

    # We may not see the head
    translated_player = translate_player(player, {11,10}, {10,10})
    assert translated_player.position == nil
    assert translated_player.tail == [{0, 0}, {1, 0}, {2, 0}, {3, 0}, {4, 0}]
  end

  test "move_players/1" do
    pid = spawn(fn -> true end)
    game = new([{8,10}])
    |> spawn_player(pid, {10,10}, :left)

    # Move the player left
    game = move_players(game)
    assert %Game{players: %{^pid => %Player{position: {9, 10}, tail: []}},
                 pellets: %{{8,10} => true}} = game


    # Move the player left, eating the pellet
    game = move_players(game)
    assert %Game{players: %{^pid => %Player{position: {8, 10}, tail: [{9,10}]}},
                 pellets: %{}} = game
  end
end