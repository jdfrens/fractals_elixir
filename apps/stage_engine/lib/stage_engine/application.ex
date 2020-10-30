defmodule StageEngine.Application do
  @moduledoc false

  use Application

  alias Fractals.ParserRegistry

  @impl Application
  def start(_type, _args) do
    {:ok, _} = Application.ensure_all_started(:fractals)

    ParserRegistry.add(:engine, :stage, StageEngine)

    children = [
      StageEngine.GridWorker,
      StageEngine.EscapeTimeWorker,
      StageEngine.ColorSchemeWorker,
      StageEngine.OutputManager
    ]

    opts = [strategy: :one_for_one, name: StageEngine.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
