defmodule Fractals.Reporters.Stdout do
  @moduledoc """
  Outputs messages to stdout.
  """

  use GenServer

  # client

  def start_link(opts) do
    puts = Keyword.get(opts, :puts, &IO.puts/1)
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, [puts: puts], name: name)
  end

  # server

  @impl GenServer
  def init(state) do
    {:ok, state}
  end

  @impl GenServer
  def handle_cast({:starting, job, _opts}, state) do
    puts(state, "starting #{job.output.filename}")
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:writing, job, opts}, state) do
    chunk_number = Keyword.get(opts, :chunk_number)
    chunk_count = job.engine.chunk_count

    if Integer.mod(chunk_number, 20) == 0 or chunk_number == chunk_count do
      puts(state, "writing #{chunk_number}/#{chunk_count} to #{job.output.ppm_filename}")
    end

    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:skipping, job, opts}, state) do
    reason = Keyword.get(opts, :reason)
    puts(state, "skipping #{job.output.filename}: #{reason}")
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:done, job, _opts}, state) do
    puts(state, "finished #{job.output.filename}")
    {:noreply, state}
  end

  @spec puts(keyword, String.t()) :: :ok
  defp puts(state, message) do
    state[:puts].(message)
  end
end
