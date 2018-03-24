defmodule SSHnakes.Formatter do
  alias IO.ANSI
  def format_game(x,y) do
    [ANSI.clear,
     cursor(y,x),
     "X",
     ANSI.reset,
     ANSI.home]
  end

  defp cursor(line, column)
    when is_integer(line) and line >= 0 and is_integer(column) and column >= 0 do
    "\e[#{line};#{column}H"
  end
end