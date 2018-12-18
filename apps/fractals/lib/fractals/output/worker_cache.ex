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

  @spec build_initial_cache(integer()) :: map
  def build_initial_cache(chunk_count) do
    %{(chunk_count + 1) => :done}
  end

  @spec process(OutputState.t(), Chunk.t(), (Job.t() -> any)) :: OutputState.t() | nil
  def process(%OutputState{next_number: next_number, cache: cache}, chunk, next_stage) do
    cache
    |> update_cache(chunk)
    |> output_cache(next_number, chunk.job, next_stage)
  end

  @spec update_cache(map, Chunk.t()) :: map
  def update_cache(cache, %Chunk{number: number, data: pixels}) do
    Map.put(cache, number, pixels)
  end

  @spec output_cache(
          map,
          non_neg_integer,
          Job.t(),
          (Job.t() -> any)
        ) :: OutputState.t() | nil
  def output_cache(cache, next_number, job, next_stage) do
    case Map.get(cache, next_number) do
      nil ->
        %OutputState{next_number: next_number, cache: cache}

      :done ->
        next_stage.(job)
        nil

      pixels ->
        write_chunk(next_number, pixels, job)

        cache
        |> Map.delete(next_number)
        |> output_cache(next_number + 1, job, next_stage)
    end
  end

  @spec write_chunk(non_neg_integer(), [String.t()], Job.t()) :: Job.t()
  defp write_chunk(chunk_number, pixels, job) do
    Broadcaster.report(:writing, job, chunk_number: chunk_number)
    job.output.module.write(job, pixels)
  end
end
