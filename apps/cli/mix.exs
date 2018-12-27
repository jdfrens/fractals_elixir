defmodule CLI.MixProject do
  use Mix.Project

  def project do
    [
      app: :cli,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7",
      escript: [main_module: CLI, name: "fractals"],
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:fractals, in_umbrella: true},
      {:ppm_output, in_umbrella: true},
      {:png_output, in_umbrella: true},
      {:stage_engine, in_umbrella: true},
      {:uniprocess_engine, in_umbrella: true}
    ]
  end
end
