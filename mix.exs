defmodule SSHnakes.MixProject do
  use Mix.Project

  def project do
    [
      app: :sshnakes,
      version: "0.1.0",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {SSHnakes.Application, []}
    ]
  end

  defp aliases do
    [
      test: "test --no-start"
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end

   # Specifies which paths to compile per environment.
   defp elixirc_paths(:test), do: ["lib", "test/support"]
   defp elixirc_paths(_),     do: ["lib"]
end
