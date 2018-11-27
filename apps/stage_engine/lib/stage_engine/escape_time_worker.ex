defmodule StageEngine.EscapeTimeWorker do
  @moduledoc """
  Process that runs the right escape-time algorithm for the specified fractal.
  """

  use GenStage

  alias Fractals.Chunk

  # Client

  @spec start_link(keyword) :: GenServer.on_start()
  def start_link(_) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  # Server

  @impl GenStage
  def init(:ok) do
    {:producer_consumer, :ok, subscribe_to: [{StageEngine.GridWorker, max_demand: 10}]}
  end

  @impl GenStage
  def handle_events(events, _from, :ok) do
    escaped =
      Enum.map(events, fn %Chunk{job: job} = chunk ->
        %{chunk | data: job.fractal.module.generate(chunk.data, job.fractal)}
      end)

    {:noreply, escaped, :ok}
  end
end
