defmodule Ff.MixProject do
  use Mix.Project

  def project do
    [
      app: :ff,
      version: "0.1.0",
      elixir: "~> 1.6",
      escript: [main_module: FF.CLI],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [:httpoison],
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.4"},
      {:poison, "~> 2.2"},
      {:netrc, "~> 0.0.1"}
    ]
  end
end
