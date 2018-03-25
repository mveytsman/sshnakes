defmodule SSHnakes.TestHelpers do
  @moduledoc """
  Functions in this module are imported in all test modules
  """

  @doc "We need pids for keys for maps"
  def new_pid() do
    # This seems to be the best way to get a unique pid
    spawn(fn -> true end)
  end
end
