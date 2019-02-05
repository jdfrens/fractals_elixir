defmodule PPMOutput.MixProject do
  @moduledoc false

  use Mix.Project

  def project do
    [
      app: :ppm_output,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {PPMOutput.Application, []}
    ]
  end

  defp deps do
    [
      {:fractals, in_umbrella: true},
      {:ppm, in_umbrella: true}
    ]
  end
end
