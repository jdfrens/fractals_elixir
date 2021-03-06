defmodule StageEngine.MixProject do
  use Mix.Project

  def project do
    [
      app: :stage_engine,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.10",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {StageEngine.Application, []}
    ]
  end

  defp deps do
    [
      {:fractals, in_umbrella: true},
      {:gen_stage, "~> 1.0"}
    ]
  end
end
