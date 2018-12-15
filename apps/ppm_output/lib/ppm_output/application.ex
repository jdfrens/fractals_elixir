defmodule PPMOutput.Application do
  @moduledoc false

  use Application

  alias Fractals.ParserRegistry

  def start(_type, _args) do
    Application.ensure_all_started(:fractals)
    ParserRegistry.add(:output, "ppm", PPMOutput)

    children = []

    opts = [strategy: :one_for_one, name: PPMOutput.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
