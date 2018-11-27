defmodule Fractals.ConversionWorker do
  @moduledoc """
  Process that converts image files to other formats (e.g., PPM to PNG).
  """

  @type convert :: (String.t(), String.t() -> any)
  @type broadcast :: (atom, Fractals.Job.t(), keyword -> any)

  use GenServer

  alias Fractals.{ImageMagick, Job, Reporters.Broadcaster}

  # Client

  @spec start_link(keyword) :: GenServer.on_start()
  def start_link(options \\ []) do
    convert = Keyword.get(options, :convert, &ImageMagick.convert/2)
    broadcast = Keyword.get(options, :broadcast, &Broadcaster.report/3)
    name = Keyword.get(options, :name, __MODULE__)

    state = %{
      convert: convert,
      broadcast: broadcast
    }

    GenServer.start_link(__MODULE__, state, name: name)
  end

  @spec convert(pid | atom, Job.t()) :: :ok
  def convert(pid \\ __MODULE__, job) do
    GenServer.cast(pid, {:convert, job})
  end

  # Server

  @impl GenServer
  def init(state) do
    {:ok, state}
  end

  @impl GenServer
  def handle_cast({:convert, job}, %{convert: convert, broadcast: broadcast} = state) do
    extension = Path.extname(job.output.filename)
    convert_to(job.output, extension, convert)
    done(broadcast, job)

    {:noreply, state}
  end

  @spec convert_to(Fractals.Output.t(), String.t(), convert()) :: Fractals.Output.t()
  defp convert_to(output, ".ppm", _convert) do
    # OutputWorker already wrote a PPM file
    output
  end

  defp convert_to(output, ".png", convert) do
    root_filename =
      output.filename
      |> Path.rootname(".png")
      |> Path.rootname(".ppm")

    ppm_filename = root_filename <> ".ppm"
    convert.(ppm_filename, output.filename)

    output
  end

  @spec done(broadcast(), Job.t()) :: any
  defp done(broadcast, job) do
    broadcast.(:done, job, from: self())
  end
end
