defmodule PPMOutput.Application do
  @moduledoc false

  use Application

  alias Fractals.ParserRegistry

  @impl Application
  def start(_type, _args) do
    {:ok, _} = Application.ensure_all_started(:fractals)

    ParserRegistry.add(:output, :ppm, PPMOutput.Parser)

    children = []

    opts = [strategy: :one_for_one, name: PPMOutput.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
