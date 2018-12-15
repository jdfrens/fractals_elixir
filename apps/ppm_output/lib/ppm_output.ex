defmodule PPMOutput do
  @moduledoc """
  Represents  the output values for a job.
  """

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
    PPMFile.lines_to_file(job, pixels)
    job
  end
end
