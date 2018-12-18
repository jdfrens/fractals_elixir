defmodule Fractals.ColorScheme do
  @moduledoc """
  This finds the right color scheme as specified in the job.
  """

  alias Fractals.ColorScheme.{BlackAndWhiteAndGray, Random, WarpPov}

  @spec color_point({Complex.complex(), non_neg_integer}, Fractals.Job.t()) :: PPM.color()
  def color_point({_, iterations}, job) do
    case job.color.type do
      :black_on_white -> BlackAndWhiteAndGray.black_on_white(iterations, job)
      :white_on_black -> BlackAndWhiteAndGray.white_on_black(iterations, job)
      :gray -> BlackAndWhiteAndGray.gray(iterations, job)
      :red -> WarpPov.red(iterations, job)
      :green -> WarpPov.green(iterations, job)
      :blue -> WarpPov.blue(iterations, job)
      :random -> Random.at(Random, iterations, job)
    end
  end
end
