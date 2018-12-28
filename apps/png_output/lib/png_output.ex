defmodule PNGOutput do
  @moduledoc """
  Generate PNG output.

  Since PNG output must by done row by row, this module defers most of the work to `PNGOutput.BufferedOutput`.
  """

  use Fractals.Output

  alias Fractals.Color
  alias PNGOutput.BufferedOutput

  @type t :: %__MODULE__{
          type: :png,
          module: __MODULE__,
          directory: String.t() | nil,
          filename: String.t() | nil,
          max_intensity: non_neg_integer() | nil,
          pid: pid() | nil
        }

  defstruct type: :png,
            module: __MODULE__,
            directory: "images",
            filename: nil,
            max_intensity: 255,
            pid: nil

  @buffered_supervisor PNGOutput.BufferedOutputSupervisor

  @impl Fractals.Output
  def open(job) do
    {:ok, pid} = DynamicSupervisor.start_child(@buffered_supervisor, {BufferedOutput, job})

    pid
  end

  @impl Fractals.Output
  def start(state) do
    GenServer.call(state.pid, {:start})
    state
  end

  @impl Fractals.Output
  def write(state, pixels) do
    converted_pixels = Enum.map(pixels, &rgb_to_ints(&1, state.max_intensity))
    GenServer.call(state.pid, {:write, converted_pixels})
    state
  end

  @impl Fractals.Output
  def stop(state) do
    GenServer.call(state.pid, {:stop})
    state
  end

  @impl Fractals.Output
  def close(state) do
    GenServer.call(state.pid, {:close})
    DynamicSupervisor.terminate_child(@buffered_supervisor, state.pid)
    state
  end

  @spec rgb_to_ints(Color.rgb(), non_neg_integer()) :: PPM.t()
  defp rgb_to_ints(rgb, max_intensity) do
    {:rgb_int, red, green, blue, _max_intensity} = Color.rgb_int(rgb, max_intensity)
    <<red, green, blue>>
  end
end
