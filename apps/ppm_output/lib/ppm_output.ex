defmodule PPMOutput do
  @moduledoc """
  Represents  the output values for a job.
  """

  alias Fractals.Color
  alias PPMOutput.File, as: PPMFile

  @behaviour Fractals.Output

  @type t :: %__MODULE__{
          type: :ppm,
          module: __MODULE__,
          directory: String.t() | nil,
          filename: String.t() | nil,
          pid: pid() | nil
        }

  defstruct type: :ppm,
            module: __MODULE__,
            directory: "images",
            filename: nil,
            pid: nil

  @impl Fractals.Output
  def start(job) do
    PPMFile.lines_to_file(job, PPMFile.header(job))
    job
  end

  @impl Fractals.Output
  def write(job, pixels) do
    max_intensity = job.color.max_intensity
    ppm_lines = Enum.map(pixels, &rgb_to_ppm(&1, max_intensity))
    PPMFile.lines_to_file(job, ppm_lines)
    job
  end

  @spec rgb_to_ppm(Color.rgb(), non_neg_integer()) :: PPM.t()
  defp rgb_to_ppm(rgb, max_intensity) do
    rgb
    |> Color.rgb_int(max_intensity)
    |> PPM.ppm()
  end
end
