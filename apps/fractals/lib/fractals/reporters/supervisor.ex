defmodule Fractals.Reporters.Supervisor do
  @moduledoc """
  Supervises reporters.

  Use `Fractals.Reporters.Broadcaster.add_reporter/2` to add more reporters.
  """

  use DynamicSupervisor

  @spec start_link(list(module())) :: Supervisor.on_start()
  def start_link(reporters \\ []) do
    DynamicSupervisor.start_link(__MODULE__, reporters, name: __MODULE__)
  end

  @spec add_reporter(module(), keyword()) :: DynamicSupervisor.on_start_child()
  def add_reporter(reporter, args \\ []) do
    child_spec = %{
      id: reporter,
      start: {reporter, :start_link, [args]}
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  @impl DynamicSupervisor
  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
