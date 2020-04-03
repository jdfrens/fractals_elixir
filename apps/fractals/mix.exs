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
      extra_applications: [:complex_num, :logger, :yaml_elixir],
      mod: {Fractals.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_env), do: ["lib"]

  defp deps do
    [
      {:complex, in_umbrella: true},
      {:earmark, "~> 1.2", override: true},
      {:inflex, "~> 2.0.0"},
      {:mox, "~> 0.4", only: :test},
      {:ppm, in_umbrella: true},
      {:stream_data, "~> 0.1", only: [:dev, :test]},
      {:uuid, "~> 1.1"},
      {:yaml_elixir, "~> 2.4.0"}
    ]
  end

  defp aliases do
    [
      all: ["test", "mix format --check-formatted", "credo --strict"]
    ]
  end
end
