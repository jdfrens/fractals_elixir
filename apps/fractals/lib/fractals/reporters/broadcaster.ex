defmodule Fractals.Reporters.Broadcaster do
  @moduledoc """
  Broadcasts messages to reporters.
  """

  use GenServer

  alias Fractals.Job
  alias Fractals.Reporters.Supervisor

  # client

  @spec start_link(list(module())) :: GenServer.on_start()
  def start_link(reporters \\ []) do
    GenServer.start_link(__MODULE__, reporters, name: __MODULE__)
  end

  @spec add_reporter(module, any) :: :ok
  def add_reporter(reporter, args \\ []) do
    GenServer.call(__MODULE__, {:add, reporter, args})
  end

  @spec report(atom, Job.t(), keyword) :: :ok
  def report(tag, job, opts \\ []) do
    GenServer.cast(__MODULE__, {:report, {tag, job, opts}})
  end

  # server

  @impl GenServer
  def init(reporters) do
    {:ok, reporters}
  end

  @impl GenServer
  def handle_call({:add, reporter, args}, _from, reporters) do
    {:ok, pid} = Supervisor.add_reporter(reporter, args)
    Process.monitor(pid)
    {:reply, :ok, [pid | reporters]}
  end

  @impl GenServer
  def handle_cast({:report, {tag, job, opts}}, reporters) do
    Enum.each(reporters, fn reporter ->
      GenServer.cast(reporter, {tag, job, opts})
    end)

    {:noreply, reporters}
  end

  @impl GenServer
  def handle_info({:DOWN, _ref, :process, pid, _reason}, reporters) do
    {:noreply, List.delete(reporters, pid)}
  end
end
