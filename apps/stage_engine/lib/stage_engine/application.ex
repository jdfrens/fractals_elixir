defmodule StageEngine.Application do
  @moduledoc false

  use Application

  alias Fractals.EngineRegistry

  def start(_type, _args) do
    Application.ensure_all_started(:fractals)
    EngineRegistry.add("stage", StageEngine)

    children = [
      StageEngine.GridWorker,
      StageEngine.EscapeTimeWorker,
      StageEngine.ColorizerWorker,
      StageEngine.OutputManager
    ]

    opts = [strategy: :one_for_one, name: StageEngine.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
