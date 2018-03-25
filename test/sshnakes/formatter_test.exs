defmodule SSHnakes.FormatterTest do
  use SSHnakes.TestCase, async: true
  alias IO.ANSI
  alias SSHnakes.Game.Player
  alias SSHnakes.Game.Impl
  import SSHnakes.Formatter

  test "format_viewport/1" do
    # we need some dummy pids for our players
    pid1 = new_pid
    pid2 = new_pid
    viewport = Impl.new([{1,2}])
    |> Impl.spawn_player(pid1, {7,8})
    |> Impl.spawn_player(pid2, {9,10})

    assert format_viewport(viewport)  ==
    [ANSI.clear,
    [["\e[2;1H", "x"]],
    [[["\e[8;7H", "@"], []],
     [["\e[10;9H", "@"], []]],
    ANSI.reset,
    ANSI.home]
  end

  test "format_pellets/1" do
    assert format_pellets([]) == []

    assert format_pellets(%{{1,2} => true}) == [["\e[2;1H", "x"]]
    assert format_pellets(%{{1,2} => true, {3,4} => true}) == [["\e[2;1H", "x"], ["\e[4;3H", "x"]]
  end

  test "format_player/1" do
    player = Player.new({1,2}, :right)
    assert format_player(player) == [["\e[2;1H", "@"], []]

    player = Player.grow(player)
    assert format_player(player) == [["\e[2;2H", "@"], [["\e[2;1H", "o"]]]

    # Sometimes we have a player without a head
    player = %{player | position: nil}
    assert format_player(player) == [[], [["\e[2;1H", "o"]]]
  end

  test "format_players/1" do
    # we need some dummy pids for our players
    pid1 = new_pid
    pid2 = new_pid
    player1 = Player.new({1,2}, :right)
    player2 = Player.new({3,4}, :right)
    players = %{pid1 => player1, pid2 => player2}

    assert format_players(players) == [format_player(player1), format_player(player2)]
  end
end
