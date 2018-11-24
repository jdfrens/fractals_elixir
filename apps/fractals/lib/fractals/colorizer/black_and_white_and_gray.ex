defmodule Fractals.Colorizer.BlackAndWhiteAndGray do
  @moduledoc """
  Colorizers for black-on-white, white-on-black, and grayscale.
  """

  import Fractals.EscapeTime.Helpers

  alias Fractals.Job

  @spec black_on_white(integer, Job.t()) :: PPM.color()
  def black_on_white(iterations, %Job{max_iterations: max_iterations})
      when inside?(iterations, max_iterations),
      do: PPM.black()

  def black_on_white(_, _), do: PPM.white()

  @spec white_on_black(integer, Job.t()) :: PPM.color()
  def white_on_black(iterations, %Job{max_iterations: max_iterations})
      when inside?(iterations, max_iterations),
      do: PPM.white()

  def white_on_black(_, _), do: PPM.black()

  @spec gray(integer, Job.t()) :: PPM.color()
  def gray(iterations, %Job{max_iterations: max_iterations})
      when inside?(iterations, max_iterations),
      do: PPM.black()

  def gray(iterations, job) do
    factor = :math.sqrt(iterations / job.max_iterations)
    intensity = round(job.max_intensity * factor)
    PPM.ppm(intensity, intensity, intensity)
  end
end
