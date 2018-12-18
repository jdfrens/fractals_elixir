defmodule PPMOutput.File do
  @moduledoc """
  Functions to write a fractal to a PPM file.  Implements the `Fractals.Output.ImageFile` behaviour.
  """

  alias Fractals.Job

  @doc """
  PPM header for P3 format.
  """
  @spec header(Job.t()) :: [String.t()]
  def header(params) do
    PPM.p3_header(params.image.size.width, params.image.size.height)
  end

  @doc """
  Writes a list of pixels to the file.
  """
  @spec lines_to_file(Job.t(), [String.t()]) :: :ok
  def lines_to_file(job, lines) do
    IO.write(job.output.pid, add_newlines(lines))
  end

  @spec add_newlines([String.t()]) :: iodata()
  defp add_newlines(lines) do
    Enum.map(lines, &[&1, "\n"])
  end
end
