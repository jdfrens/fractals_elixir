defmodule StageEngine.ColorizerWorker do
  @moduledoc """
  Worker to compute colors on a chunk of pixels
  """

  use GenStage

  alias Fractals.{Colorizer, Job}

  # Client

  @spec start_link(any) :: GenServer.on_start()
  def start_link(_) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  # Server

  @impl GenStage
  def init(:ok) do
    {:producer_consumer, :ok, subscribe_to: [{StageEngine.EscapeTimeWorker, max_demand: 10}]}
  end

  @impl GenStage
  def handle_events(events, _from, :ok) do
    colorized =
      Enum.map(events, fn chunk ->
        %{chunk | data: colorize(chunk.data, chunk.job)}
      end)

    {:noreply, colorized, :ok}
  end

  @spec colorize({atom, {non_neg_integer, list}}, Job.t()) :: list(String.t())
  def colorize(data, job) do
    Enum.map(data, &Colorizer.color_point(&1, job))
  end
end
