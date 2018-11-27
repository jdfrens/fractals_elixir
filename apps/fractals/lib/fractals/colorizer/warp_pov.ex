defmodule Fractals.Colorizer.WarpPov do
  @moduledoc """
  Provides color functions for each of the primary colors (red, green,
  and blue) which uses the brighted hue at the edge of a fractal, quickly
  tapering off to black as you get farther away.

  It's a cool effect, but not the most colorful.

  Taken from http://warp.povusers.org/Mandelbrot/
  """

  import Fractals.EscapeTime.Helpers

  alias Fractals.Fractal
  alias Fractals.Job

  @spec red(non_neg_integer, Job.t()) :: String.t()
  def red(iterations, job) do
    permute_red(intensities(iterations, job))
  end

  @spec green(non_neg_integer, Job.t()) :: String.t()
  def green(iterations, job) do
    permute_green(intensities(iterations, job))
  end

  @spec blue(non_neg_integer, Job.t()) :: String.t()
  def blue(iterations, job) do
    permute_blue(intensities(iterations, job))
  end

  @spec permute_red({non_neg_integer, non_neg_integer}) :: String.t()
  def permute_red({primary, secondary}) do
    PPM.ppm(primary, secondary, secondary)
  end

  @spec permute_green({non_neg_integer, non_neg_integer}) :: String.t()
  def permute_green({primary, secondary}) do
    PPM.ppm(secondary, primary, secondary)
  end

  @spec permute_blue({non_neg_integer, non_neg_integer}) :: String.t()
  def permute_blue({primary, secondary}) do
    PPM.ppm(secondary, secondary, primary)
  end

  @spec intensities(non_neg_integer, Job.t()) :: {non_neg_integer, non_neg_integer}
  def intensities(iterations, %Job{fractal: %Fractal{max_iterations: max_iterations}})
      when inside?(iterations, max_iterations),
      do: {0, 0}

  def intensities(iterations, job) do
    half_iterations = job.fractal.max_iterations / 2 - 1

    if iterations <= half_iterations do
      {scale(max(1, iterations), job), 0}
    else
      {job.image.max_intensity, scale(iterations - half_iterations, job)}
    end
  end

  @spec scale(float, Job) :: non_neg_integer
  def scale(i, job) do
    round(2.0 * (i - 1) / job.fractal.max_iterations * job.image.max_intensity)
  end
end
