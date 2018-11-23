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
  def handle_cast({:starting, params, _opts}, state) do
    state[:puts].("starting #{params.output_filename}")
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:writing, params, opts}, state) do
    chunk_number = Keyword.get(opts, :chunk_number)
    chunk_count = params.engine.chunk_count

    if Integer.mod(chunk_number, 20) == 0 or chunk_number == chunk_count do
      state[:puts].("writing #{chunk_number}/#{chunk_count} to #{params.ppm_filename}")
    end

    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:skipping, params, opts}, state) do
    reason = Keyword.get(opts, :reason)
    state[:puts].("skipping #{params.output_filename}: #{reason}")
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:done, params, _opts}, state) do
    state[:puts].("finished #{params.output_filename}")
    {:noreply, state}
  end
end
