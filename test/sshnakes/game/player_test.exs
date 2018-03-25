defmodule SSHnakes.Game.PlayerTest do
  use SSHnakes.TestCase, async: true

  import SSHnakes.Game.Player
  alias SSHnakes.Game.Player

  test "new/1" do
    player = new({1,2})
    assert player.position == {1,2}
    assert player.tail == []
  end

  test "new/2" do
    player = new({1,2}, :right)
    assert player.position == {1,2}
    assert player.direction == :right
    assert player.tail == []
  end

  test "new/3" do
    player = new({1,2}, :right, [{1,3}])
    assert player.position == {1,2}
    assert player.direction == :right
    assert player.tail == [{1,3}]
  end

  test "turn/2" do
    player = new({1,2}, :right)
    for dir <- [:up, :right, :down, :left] do
      assert turn(player, dir).direction == dir
    end
  end

  test "peek_move/1" do
    assert peek_move(new({1,2}, :up)) == {1,1}
    assert peek_move(new({1,2}, :right)) == {2,2}
    assert peek_move(new({1,2}, :down)) == {1,3}
    assert peek_move(new({1,2}, :left)) == {0,2}
  end

  test "move/1" do
    player = new({1,2})
    assert move(player) == %{player | position: peek_move(player)}
  end

  test "grow/1" do
    player = new({1,2})
    big_player = grow(player)
    assert  big_player == %{player | position: peek_move(player), tail: [player.position]}
    bigger_player = grow(big_player)
    assert  bigger_player == %{player | position: peek_move(big_player), tail: [big_player.position, player.position]}
  end
end