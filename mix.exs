defmodule App.Mixfile do
  use Mix.Project

  def project do
    [
      app: :tg_bot,
      version: "0.1.0",
      elixir: "~> 1.8",
      default_task: "server",
      description: description(),
      package: package(),
      deps: deps(),
      aliases: aliases(),
      name: "Telegram"
    ]
  end

  def application do
    [
      mod: {Telegram, []},
      applications: [:logger, :nadia]
    ]
  end

  defp deps do
    [
      {:nadia, "~> 0.4.1"},
      {:ex_doc, "~> 0.14"},
      {:poison, "~> 4.0"},
      {:httpoison, "~> 1.5"}
    ]
  end

  defp aliases do
    [
      server: "run --no-halt"
    ]
  end

  defp description() do
    "Simple tool for creating Telegram bots in Elixir"
  end

  defp package() do
    [
      name: "tg_bot",
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/fly1ngDream/ex-tg-bot"}
    ]
  end
end
