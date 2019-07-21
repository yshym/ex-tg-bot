defmodule App.Mixfile do
  use Mix.Project

  def project do
    [
      app: :app,
      version: "0.1.0",
      elixir: "~> 1.3",
      default_task: "server",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      aliases: aliases(),
      name: "Telegram"
    ]
  end

  def application do
    [
      applications: [:logger, :nadia],
      mod: {App, []}
    ]
  end

  defp deps do
    [
      {:nadia, "~> 0.4.1"},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false}
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
      links: %{"GitHub" => ""}
    ]
  end
end
