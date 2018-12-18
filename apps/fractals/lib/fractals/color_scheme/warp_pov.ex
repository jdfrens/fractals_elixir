defmodule Fractals.ColorScheme.WarpPov do
  @moduledoc """
  Provides color functions for each of the primary colors (red, green,
  and blue) which uses the brighted hue at the edge of a fractal, quickly
  tapering off to black as you get farther away.

  It's a cool effect, but not the most colorful.

  Taken from http://warp.povusers.org/Mandelbrot/
  """

  import Fractals.EscapeTime.Helpers

  alias Fractals.{Color, Fractal, Job}

  @doc """
  Generates a red color scaled by the number of iterations it took to escape.
  """
  @spec red(non_neg_integer(), Job.t()) :: Color.t()
  def red(iterations, job) do
    permute_red(intensities(iterations, job))
  end

  @doc """
  Generates a green color scaled by the number of iterations it took to escape.
  """
  @spec green(non_neg_integer(), Job.t()) :: Color.t()
  def green(iterations, job) do
    permute_green(intensities(iterations, job))
  end

  @doc """
  Generates a blue color scaled by the number of iterations it took to escape.
  """
  @spec blue(non_neg_integer(), Job.t()) :: Color.t()
  def blue(iterations, job) do
    permute_blue(intensities(iterations, job))
  end

  @doc """
  Permutes primary-and-secondary intensities from `intensities/2` for a red color.
  """
  @spec permute_red({float(), float()}) :: Color.t()
  def permute_red({primary, secondary}) do
    Color.rgb(primary, secondary, secondary)
  end

  @doc """
  Permutes primary-and-secondary intensities from `intensities/2` for a green color.
  """
  @spec permute_green({float(), float()}) :: Color.t()
  def permute_green({primary, secondary}) do
    Color.rgb(secondary, primary, secondary)
  end

  @doc """
  Permutes primary-and-secondary intensities from `intensities/2` for a blue color.
  """
  @spec permute_blue({float(), float()}) :: Color.t()
  def permute_blue({primary, secondary}) do
    Color.rgb(secondary, secondary, primary)
  end

  @doc """
  Computes primary and secondary intensities scaled by the number of iterations to escape.
  """
  @spec intensities(non_neg_integer(), Job.t()) :: {float(), float()}
  def intensities(iterations, %Job{fractal: %Fractal{max_iterations: max_iterations}})
      when inside?(iterations, max_iterations),
      do: {0.0, 0.0}

  def intensities(iterations, job) do
    half_iterations = job.fractal.max_iterations / 2 - 1

    if iterations <= half_iterations do
      {scale(max(1, iterations), job), 0.0}
    else
      {1.0, scale(iterations - half_iterations, job)}
    end
  end

  @doc """
  Scales an intensity.
  """
  @spec scale(float(), Job.t()) :: float()
  def scale(i, job) do
    2.0 * (i - 1) / job.fractal.max_iterations
  end
end
