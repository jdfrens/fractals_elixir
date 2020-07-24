defmodule Fractals.Mixfile do
  use Mix.Project

  def project do
    [
      app: :fractals,
      version: "0.0.1",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :yaml_elixir],
      mod: {Fractals.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_env), do: ["lib"]

  defp deps do
    [
      {:complex, github: "jdfrens/elixir-complex", ref: "51e2804"},
      {:earmark, "~> 1.2", override: true},
      {:inflex, "~> 2.1.0"},
      {:mox, "~> 0.4", only: :test},
      {:ppm, in_umbrella: true},
      {:stream_data, "~> 0.1", only: :test},
      {:uuid, "~> 1.1"},
      {:yaml_elixir, "~> 2.5.0"}
    ]
  end

  defp aliases do
    [
      all: ["test", "mix format --check-formatted", "credo --strict"]
    ]
  end
end
