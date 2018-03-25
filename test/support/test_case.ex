defmodule SSHnakes.TestCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import SSHnakes.TestHelpers
    end
  end
end
