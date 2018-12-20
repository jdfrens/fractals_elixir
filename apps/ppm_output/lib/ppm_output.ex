defmodule PPMOutput do
  @moduledoc """
  Represents  the output values for a job.
  """

  alias Fractals.{Color, Job}
  alias PPMOutput.File, as: PPMFile

  @behaviour Fractals.Output

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
  def write_everything(job, pixels) do
    pid = start(job)
    max_intensity = job.output.max_intensity
    ppm_lines = Enum.map(pixels, &rgb_to_ppm(&1, max_intensity))
    PPMFile.lines_to_file(pid, ppm_lines)
    job
  end

  @impl Fractals.Output
  def start(job) do
    with %Job{output: output} <- job,
         filename when is_binary(filename) <- output.filename,
         {:ok, pid} <- File.open(filename, [:write]) do
      PPMFile.lines_to_file(pid, PPMFile.header(job))
      pid
    end
  end

  @impl Fractals.Output
  def write(job, output_state, pixels) do
    max_intensity = job.output.max_intensity
    ppm_lines = Enum.map(pixels, &rgb_to_ppm(&1, max_intensity))
    PPMFile.lines_to_file(output_state.pid, ppm_lines)
    job
  end

  @impl Fractals.Output
  def stop(output_state) do
    File.close(output_state.pid)
  end

  @spec rgb_to_ppm(Color.rgb(), non_neg_integer()) :: PPM.t()
  defp rgb_to_ppm(rgb, max_intensity) do
    rgb
    |> Color.rgb_int(max_intensity)
    |> PPM.ppm()
  end
end
