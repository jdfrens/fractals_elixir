defmodule Fractals.Output.WorkerCache do
  @moduledoc """
  Cache for `OutputWorker`.

  Chunks may come in out of order.  This cache will cache the chunks that need to wait.  Chunks are always added to the
  cache first, and then the "next" chunk is searched from the cache.  As long as a "next" chunk is found, it's
  processed, and the search-process loop repeats.
  """

  alias Fractals.{Chunk, Color}
  alias Fractals.Output.OutputState
  alias Fractals.Reporters.Broadcaster

  @type t :: map()

  @doc """
  Creates a new cache of chunks of image waiting for output.
  """
  @spec new(integer()) :: t()
  def new(chunk_count) do
    %{(chunk_count + 1) => :done}
  end

  @doc """
  Adds another chunk to the cache.  The cache is flushed as much as it can be after the new chunk is added.
  """
  @spec next_chunk(OutputState.t(), Chunk.t()) :: OutputState.t() | nil
  def next_chunk(state, chunk) do
    state
    |> update_cache(chunk)
    |> output_cache()
  end

  @spec update_cache(OutputState.t(), Chunk.t()) :: OutputState.t()
  defp update_cache(state, %Chunk{number: number, data: pixels}) do
    %{state | cache: Map.put(state.cache, number, pixels)}
  end

  @spec output_cache(OutputState.t()) :: OutputState.t()
  defp output_cache(state) do
    case Map.get(state.cache, state.next_number) do
      nil -> state
      :done -> done(state)
      pixels -> write(state, pixels)
    end
  end

  @spec done(OutputState.t()) :: OutputState.t()
  defp done(state) do
    state.output_module.stop(state)
    state.output_module.close(state)
    Broadcaster.report(:done, state.job, from: self())

    state
  end

  @spec write(OutputState.t(), [Color.t()]) :: OutputState.t()
  defp write(state, pixels) do
    state.output_module.write(state, pixels)
    Broadcaster.report(:writing, state.job, chunk_number: state.next_number)

    state
    |> Map.update!(:cache, &Map.delete(&1, :next_number))
    |> Map.update!(:next_number, &(&1 + 1))
    |> output_cache()
  end
end
