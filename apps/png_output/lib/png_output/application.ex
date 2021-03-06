defmodule PNGOutput.Application do
  @moduledoc false

  use Application

  alias Fractals.ParserRegistry

  @impl Application
  def start(_type, _args) do
    {:ok, _} = Application.ensure_all_started(:fractals)

    ParserRegistry.add(:output, :png, PNGOutput.Parser)

    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: PNGOutput.BufferedOutputSupervisor}
    ]

    opts = [strategy: :one_for_one, name: PNGOutput.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
