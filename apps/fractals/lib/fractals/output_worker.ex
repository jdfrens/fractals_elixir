defmodule Fractals.OutputWorker do
  @moduledoc """
  Worker to close out a file when it is completely written.

  A callback function is also called for further processing once the file is closed.
  """

  use GenServer

  alias Fractals.{Chunk, Job}
  alias Fractals.Output.{OutputState, WorkerCache}

  @type via_tuple :: {:via, Registry, {Fractals.OutputWorkerRegistry, Job.fractal_id()}}

  # Client API

  @doc """
  Writes a chunk of data to an output worker.

  Use `write/1`.  It will create an output worker for the fractal if one has not already been started.

  Use `write/2` if you want to micromanage which output worker processes the chunk.  Used to test this worker.
  """
  @spec write(GenServer.name(), Chunk.t()) :: :ok
  def write(pid \\ nil, chunk)

  def write(nil, chunk) do
    write(via_tuple(chunk.job.id), chunk)
  end

  def write(pid, chunk) do
    maybe_new(name: pid)
    GenServer.cast(pid, {:write, chunk})
  end

  @doc """
  Starts an output worker.

  Don't use this.  It should be used as part of a `DynamicSupervisor` which is handled by `write/1`.  This function is
  useful for testing.
  """
  @spec start_link(atom) :: GenServer.on_start()
  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  @spec via_tuple(Job.fractal_id()) :: via_tuple()
  defp(via_tuple(fractal_id)) do
    {:via, Registry, {Fractals.OutputWorkerRegistry, fractal_id}}
  end

  # Creates a new worker if needed.
  @spec maybe_new(keyword) :: Supervisor.on_start_child()
  defp maybe_new(options) do
    name = Keyword.get(options, :name)
    supervisor = Fractals.OutputWorkerSupervisor
    child_spec = {__MODULE__, name}

    case DynamicSupervisor.start_child(supervisor, child_spec) do
      {:error, {:already_started, pid}} ->
        {:ok, pid}

      response ->
        response
    end
  end

  # Server API

  @impl GenServer
  def init(_) do
    {:ok, nil}
  end

  @impl GenServer
  def handle_cast({:write, chunk}, nil) do
    output_module = chunk.job.output.module
    max_intensity = chunk.job.output.max_intensity
    chunk_count = chunk.job.engine.chunk_count

    state =
      %OutputState{
        job: chunk.job,
        output_module: output_module,
        max_intensity: max_intensity,
        next_number: 1,
        pid: output_module.open(chunk.job),
        cache: WorkerCache.new(chunk_count)
      }
      |> output_module.start()
      |> WorkerCache.next_chunk(chunk)

    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:write, chunk}, state) do
    updated_state = WorkerCache.next_chunk(state, chunk)

    {:noreply, updated_state}
  end
end
