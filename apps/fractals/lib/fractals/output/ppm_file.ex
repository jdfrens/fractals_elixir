defmodule Fractals.Output.PPMFile do
  @moduledoc """
  Functions to write a fractal to a PPM file.  Implements the `Fractals.Output.ImageFile` behaviour.
  """

  @behaviour Fractals.Output.ImageFile

  alias Fractals.Job

  @impl Fractals.Output.ImageFile
  def write_file(job, pixels) do
    start_file(job)
    write_pixels(job, pixels)
  end

  @impl Fractals.Output.ImageFile
  def start_file(job) do
    lines_to_file(job, header(job))
  end

  @impl Fractals.Output.ImageFile
  def write_pixels(job, pixels) do
    lines_to_file(job, pixels)
  end

  @spec header(Job.t()) :: [String.t()]
  defp header(params) do
    PPM.p3_header(params.image.size.width, params.image.size.height)
  end

  @spec lines_to_file(Job.t(), [String.t()]) :: :ok
  defp lines_to_file(job, lines) do
    IO.write(job.output.pid, add_newlines(lines))
  end

  @spec add_newlines([String.t()]) :: [[String.t()]]
  defp add_newlines(lines) do
    Enum.map(lines, &[&1, "\n"])
  end
end
