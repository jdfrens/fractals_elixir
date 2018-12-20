defmodule Fractals.Output.WorkerCache do
  @moduledoc """
  Cache for `OutputWorker`.

  Chunks may come in out of order.  This cache will cache the chunks that need to wait.  Chunks are always added to the
  cache first, and then the "next" chunk is searched from the cache.  As long as a "next" chunk is found, it's
  processed, and the search-process loop repeats.
  """

  alias Fractals.{Chunk, Job}
  alias Fractals.Output.OutputState
  alias Fractals.Reporters.Broadcaster

  @doc """
  Creates a new cache of chunks of image waiting for output.
  """
  @spec new(integer()) :: map
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
    |> output_cache(chunk.job)
  end

  @spec update_cache(OutputState.t(), Chunk.t()) :: OutputState.t()
  defp update_cache(state, %Chunk{number: number, data: pixels}) do
    %{state | cache: Map.put(state.cache, number, pixels)}
  end

  @spec output_cache(OutputState.t(), Job.t()) :: OutputState.t() | nil
  defp output_cache(state, job) do
    case Map.get(state.cache, state.next_number) do
      nil ->
        state

      :done ->
        state.next_stage.(job)
        nil

      pixels ->
        write_chunk(state, pixels, job)

        state
        |> Map.update!(:cache, &Map.delete(&1, :next_number))
        |> Map.update!(:next_number, &(&1 + 1))
        |> output_cache(job)
    end
  end

  @spec write_chunk(OutputState.t(), [String.t()], Job.t()) :: Job.t()
  defp write_chunk(state, pixels, job) do
    Broadcaster.report(:writing, job, chunk_number: state.next_number)
    job.output.module.write(job, state, pixels)
  end
end
