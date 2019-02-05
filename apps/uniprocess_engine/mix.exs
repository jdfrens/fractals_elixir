defmodule UniprocessEngine.MixProject do
  use Mix.Project

  def project do
    [
      app: :uniprocess_engine,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.8",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {UniprocessEngine.Application, []}
    ]
  end

  defp deps do
    [
      {:fractals, in_umbrella: true}
    ]
  end
end
