defmodule Fractals.Output.PPMFile do
  @moduledoc """
  Functions to write a fractal to a PPM file.
  """

  @type pixel :: String.t()
  @type pixels :: [pixel()]

  alias Fractals.Job

  @doc """
  Writes all of the `pixels` to a new file.
  """
  @spec write_file(Job.t(), pixels()) :: :ok
  def write_file(job, pixels) do
    start_file(job)
    write_pixels(job, pixels)
  end

  @doc """
  Writes the PPM header to a new file.
  """
  @spec start_file(Job.t()) :: :ok
  def start_file(job) do
    lines_to_file(job, header(job))
  end

  @doc """
  Writes pixels to file that has been started with `start_file/1`.
  """
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
