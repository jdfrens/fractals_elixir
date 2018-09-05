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
      dialyzer: [ignore_warnings: ".dialyzer-ignore-warnings"],
      aliases: aliases()
    ]
  end

  def application do
    [applications: [:logger, :yaml_elixir], mod: {Fractals, []}]
  end

  defp deps do
    [
      {:complex,
       github: "jdfrens/elixir-complex", ref: "a1298705f9cee017b1eda4037835dfaa9afbd4a2"},
      {:credo, "~> 0.10.0", only: [:dev, :test]},
      {:dialyxir, "~> 1.0.0-rc.2", only: [:dev], runtime: false},
      {:earmark, "~> 1.2", override: true},
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
