defmodule Fractals.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: dialyzer(),
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
      {:credo, "~> 1.3.0", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
      {:dialyxir, "~> 1.0.0-rc.2", only: [:dev, :test], runtime: false}
    ]
  end

  # NOTE: skipping :no_*, :underspecs, :overspecs, :specdiffs
  @dialyzer_warn_opts ~w(
      error_handling
      race_conditions
      unknown
      unmatched_returns
      )a
  defp dialyzer do
    [
      plt_add_apps: [:ex_unit],
      flags: [
        "-Wunmatched_returns" | @dialyzer_warn_opts
      ],
      ignore_warnings: ".dialyzer_ignore.exs",
      list_unused_filters: true
    ]
  end

  defp aliases do
    [
      all_tests: [
        "test",
        "format --check-formatted",
        "credo --strict",
        "dialyzer --list-unused-filters --halt-exit-status"
      ]
    ]
  end
end
