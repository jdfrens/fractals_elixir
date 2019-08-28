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

  defmodule State do
    @moduledoc false
    defstruct png: nil, buffer: []
  end

  alias Fractals.{Job, Size}

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
    {:ok, %State{buffer: []}, {:continue, job}}
  end

  @impl GenServer
  def handle_continue(job, state) do
    with {:ok, output_pid} <- open_file(job),
         %PNG{} = png <- job |> build_config(output_pid) |> PNG.open() do
      {:noreply, %{state | png: png}}
    end
  end

  @impl GenServer
  def handle_call({:start}, _from, %State{png: png} = state) do
    %PNG{} =
      png
      |> PNG.write_header()
      |> PNG.write_palette()

    {:reply, :ok, state}
  end

  @impl GenServer
  def handle_call({:write, pixels}, _from, %State{png: png, buffer: buffer} = state) do
    %PNG{size: {width, _}} = png

    {rows, leftover} =
      (buffer ++ pixels)
      |> Enum.chunk_every(width)
      |> Enum.split_with(&(length(&1) == width))

    new_buffer =
      case leftover do
        [] -> []
        [new_buffer] -> new_buffer
      end

    Enum.each(rows, &PNG.write(png, {:row, &1}))

    {:reply, :ok, %{state | buffer: new_buffer}}
  end

  @impl GenServer
  def handle_call({:stop}, _from, state) do
    {:reply, :ok, state}
  end

  @impl GenServer
  def handle_call({:close}, _from, %State{png: png, buffer: []} = state) do
    :ok = PNG.close(png)
    :ok = :file.close(png.file)

    {:reply, :ok, state}
  end

  @spec open_file(Job.t()) :: {:ok, pid()}
  defp open_file(job) do
    with %Job{output: output} <- job,
         filename when is_binary(filename) <- output.filename do
      File.open(filename, [:write])
    end
  end

  @spec build_config(Job.t(), pid()) :: PNG.t()
  defp build_config(job, output_file_pid) do
    %Size{width: width, height: height} = job.image.size
    %PNG{size: {width, height}, mode: @mode, file: output_file_pid}
  end
end
