defmodule Fractals.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [
        plt_add_apps: [:ex_unit],
        ignore_warnings: ".dialyzer-ignore-warnings"
      ],
      elixir: "~> 1.8",
      test_coverage: [tool: ExCoveralls],
      aliases: aliases(),
      preferred_cli_env: [
        all_tests: :test,
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.1.0", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
      {:dialyxir, "~> 1.0.0-rc.2", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      all_tests: [
        "test",
        "format --check-formatted",
        "credo --strict",
        "dialyzer"
      ]
    ]
  end
end
