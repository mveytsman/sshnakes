defmodule SSHnakesTest do
  use ExUnit.Case
  doctest SSHnakes

  test "greets the world" do
    assert SSHnakes.hello() == :world
  end
end
