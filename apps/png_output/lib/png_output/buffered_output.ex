defmodule PNGOutput.BufferedOutput do
  @moduledoc """
  Buffers output row by row.

  PNG files must be processed row by row.  Each row needs to start with a setting for the scanline filter (see
  `PNG.low_level` which always uses 0).  Compression might also need to happen in units of rows, not pixels.

  Each job sets its own "chunk size" which is not necessarily a multiple of the image's width.  This GenServer buffers
  an incomplete row for the next time pixels are written.  The next pixels are appended to the buffer; complete rows are
  taken from that concatenation and written to the output.  The remaining partial row becomes the next buffer.

  When the output is closed, this GenServer makes sure the buffer is empty.
  """
  use GenServer

  alias Fractals.{Job, Size}
  alias PNG.{Config, LowLevel}

  @mode {:rgb, 8}

  @doc """
  Starts a process for buffered output.  Called from `PNGOutput`.
  """
  @spec start_link(Job.t()) :: GenServer.on_start()
  def start_link(job) do
    GenServer.start_link(__MODULE__, job)
  end

  @impl GenServer
  def init(%Job{} = job) do
    with {:ok, output_pid} <- open_file(job),
         buffer = [] do
      {:ok, %{output_pid: output_pid, buffer: buffer}}
    end
  end

  @impl GenServer
  def handle_call({:start, output_state}, _from, %{output_pid: output_pid} = state) do
    %Size{width: width, height: height} = output_state.job.image.size
    config = %Config{size: {width, height}, mode: @mode}

    io_data = [
      LowLevel.header(),
      LowLevel.chunk("IHDR", config)
    ]

    :ok = :file.write(output_pid, io_data)

    {:reply, output_state, state}
  end

  @impl GenServer
  def handle_call(
        {:write, output_state, pixels},
        _from,
        %{output_pid: output_pid, buffer: buffer} = state
      ) do
    width = output_state.job.image.size.width

    {rows, leftover} =
      (buffer ++ pixels)
      |> Enum.chunk_every(width)
      |> Enum.split_with(&(length(&1) == width))

    new_buffer =
      case leftover do
        [] -> []
        [new_buffer] -> new_buffer
      end

    io_data = LowLevel.chunk("IDAT", {:rows, rows})
    :ok = :file.write(output_pid, io_data)

    {:reply, output_state, %{state | buffer: new_buffer}}
  end

  @impl GenServer
  def handle_call({:stop, output_state}, _from, %{output_pid: output_pid} = state) do
    :ok =
      output_pid
      |> :file.write(LowLevel.chunk("IEND"))

    {:reply, output_state, state}
  end

  @impl GenServer
  def handle_call({:close, output_state}, _from, %{output_pid: output_pid, buffer: []} = state) do
    :ok = :file.close(output_pid)

    {:reply, output_state, state}
  end

  @spec open_file(Job.t()) :: {:ok, pid()}
  defp open_file(job) do
    with %Job{output: output} <- job,
         filename when is_binary(filename) <- output.filename do
      File.open(filename, [:write])
    end
  end
end
