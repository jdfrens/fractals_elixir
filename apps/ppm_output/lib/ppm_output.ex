defmodule PPMOutput do
  @moduledoc """
  Represents  the output values for a job.
  """

  @behaviour Fractals.Output

  @type t :: %__MODULE__{
          type: :ppm,
          module: __MODULE__,
          directory: String.t() | nil,
          filename: String.t() | nil,
          writer: PPMOutput.File,
          pid: pid() | nil
        }

  defstruct type: :ppm,
            module: __MODULE__,
            directory: "images",
            filename: nil,
            writer: PPMOutput.File,
            pid: nil

  # FIXME: part of behaviour?
  # SMELL: `data`, `colors`, `pixels` --- PICK ONE!
  def write_file(job, data) do
    start_file(job)
    write_pixels(job, data)
  end

  @impl Fractals.Output
  def start_file(job) do
    apply(job.output.writer, :start_file, [job])
    job
  end

  @impl Fractals.Output
  def write_pixels(job, data) do
    apply(job.output.writer, :write_pixels, [job, data])
    job
  end

  @impl Fractals.Output
  defdelegate parse(params), to: PPMOutput.Parser

  @impl Fractals.Output
  defdelegate compute(job), to: PPMOutput.Parser
end
