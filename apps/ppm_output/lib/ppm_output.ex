defmodule PPMOutput do
  @moduledoc """
  Represents PPM output.
  """

  use Fractals.Output

  alias Fractals.{Color, Job}
  alias PPMOutput.File, as: PPMFile

  @type t :: %__MODULE__{
          type: :ppm,
          module: __MODULE__,
          directory: String.t() | nil,
          filename: String.t() | nil,
          max_intensity: non_neg_integer() | nil
        }

  defstruct type: :ppm,
            module: __MODULE__,
            directory: "images",
            filename: nil,
            max_intensity: 255

  @impl Fractals.Output
  def open(job) do
    with %Job{output: output} <- job,
         filename when is_binary(filename) <- output.filename,
         {:ok, pid} <- File.open(filename, [:write]),
         do: pid
  end

  @impl Fractals.Output
  def start(state) do
    PPMFile.lines_to_file(state.pid, PPMFile.header(state.job))
    state
  end

  @impl Fractals.Output
  def write(state, pixels) do
    ppm_lines = Enum.map(pixels, &rgb_to_ppm(&1, state.max_intensity))
    PPMFile.lines_to_file(state.pid, ppm_lines)
    state
  end

  @impl Fractals.Output
  def stop(state), do: state

  @impl Fractals.Output
  def close(state) do
    :ok = File.close(state.pid)
    state
  end

  @spec rgb_to_ppm(Color.rgb(), non_neg_integer()) :: PPM.t()
  defp rgb_to_ppm(rgb, max_intensity) do
    rgb
    |> Color.rgb_int(max_intensity)
    |> PPM.ppm()
  end
end
