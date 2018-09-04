defmodule Fractals.Mixfile do
  use Mix.Project

  def project do
    [
      app: :fractals,
      version: "0.0.1",
      elixir: "~> 1.3",
      escript: [main_module: Fractals.CLI],
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [applications: [:logger, :yaml_elixir], mod: {Fractals, []}]
  end

  defp deps do
    [
      {:credo, "~> 0.10.0", only: [:dev, :test]},
      {:dialyxir, "~> 0.5.0", only: [:dev, :test]},
      {:gen_stage, "~> 0.14"},
      {:inflex, "~> 1.10.0"},
      {:mogrify, "~> 0.6.1"},
      {:uuid, "~> 1.1"},
      {:yaml_elixir, "~> 2.1.0"}
    ]
  end

  defp aliases do
    [
      all: ["test", "mix format --check-formatted", "credo --strict"]
    ]
  end
end
