defmodule Fractals.Output do
  @moduledoc """
  Represents  the output values for a job.
  """

  @type t :: %__MODULE__{
          directory: String.t() | nil,
          filename: String.t() | nil,
          writer: module() | nil,
          pid: pid() | nil
        }

  defstruct directory: "images", filename: nil, writer: Fractals.Output.PPMFile, pid: nil

  @spec start_file(Fractals.Job.t()) :: Fractals.Job.t()
  def start_file(job) do
    apply(job.output.writer, :start_file, [job])
    job
  end

  @spec write_pixels(Fractals.Job.t(), Fractals.Output.ImageFile.pixels()) :: Fractals.Job.t()
  def write_pixels(job, data) do
    apply(job.output.writer, :write_pixels, [job, data])
    job
  end

  defdelegate parse(params), to: Fractals.Output.Parser

  defdelegate compute(job), to: Fractals.Output.Parser
end
