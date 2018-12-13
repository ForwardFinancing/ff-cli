defmodule Ff.MixProject do
  use Mix.Project

  def project do
    [
      app: :ff,
      version: "0.1.0",
      elixir: "~> 1.6",
      escript: [
        main_module: FF.CLI,
        shebang: shebang()
      ],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [:httpoison, :timex, :tzdata],
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.4"},
      {:poison, "~> 2.2"},
      {:timex, "~> 3.1"},
      {:tzdata, "~> 0.5.19"},
      {:netrc, "~> 0.0.1"}
    ]
  end

  defp shebang do
    "#! #{System.find_executable("escript")}\n"
  end
end
