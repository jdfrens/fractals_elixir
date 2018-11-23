defmodule UniprocessEngine.Application do
  @moduledoc false

  use Application

  alias Fractals.EngineParamsParserRegistry, as: ParserRegistry

  def start(_type, _args) do
    Application.ensure_all_started(:fractals)
    ParserRegistry.add("uniprocess", UniprocessEngine.Params)

    children = []

    opts = [strategy: :one_for_one, name: UniprocessEngine.Supervisor]
    Supervisor.start_link(children, opts)
  end
end