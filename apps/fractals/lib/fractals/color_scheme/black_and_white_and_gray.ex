defmodule Fractals.ColorScheme.BlackAndWhiteAndGray do
  @moduledoc """
  Color schemes for black-on-white, white-on-black, and grayscale.
  """

  import Fractals.EscapeTime.Helpers

  alias Fractals.{Color, Fractal, Job}

  @spec black_on_white(integer, Job.t()) :: Fractals.Color.t()
  def black_on_white(iterations, %Job{fractal: %Fractal{max_iterations: max_iterations}})
      when inside?(iterations, max_iterations),
      do: Color.rgb(:black)

  def black_on_white(_, _), do: Color.rgb(:white)

  @spec white_on_black(integer, Job.t()) :: Fractals.Color.t()
  def white_on_black(iterations, %Job{fractal: %Fractal{max_iterations: max_iterations}})
      when inside?(iterations, max_iterations),
      do: Color.rgb(:white)

  def white_on_black(_, _), do: Color.rgb(:black)

  @spec gray(integer, Job.t()) :: Fractals.Color.t()
  def gray(iterations, %Job{fractal: %Fractal{max_iterations: max_iterations}})
      when inside?(iterations, max_iterations),
      do: Color.rgb(:black)

  def gray(iterations, job) do
    factor = :math.sqrt(iterations / job.fractal.max_iterations)
    Color.rgb(factor, factor, factor)
  end
end
