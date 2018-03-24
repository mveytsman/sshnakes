defmodule SSHnakes.Game do
  @width 1000
  @height 1000
  def make_board do
    for x <- 0..@width, y <- 0..@height do
      {{x,y}, nil}
    end |> Map.new
  end
end