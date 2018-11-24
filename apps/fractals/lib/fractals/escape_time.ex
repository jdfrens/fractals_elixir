defmodule Fractals.EscapeTime do
  @moduledoc """
  Implements the basic escape-time algorithm for fractals.
  """

  @type t :: [Complex.complex()]

  import Fractals.EscapeTime.Helpers
  alias Fractals.{EscapeTime, Job}
  alias Fractals.EscapeTime.{BurningShip, Julia, Mandelbrot}

  defmacro __using__(_options) do
    quote do
      @spec pixels([Complex.complex()], Job.t()) :: Fractals.EscapeTime.t()
      def pixels(grid_points, job) do
        Enum.map(grid_points, fn grid_point ->
          grid_point
          |> iterate(job)
          |> EscapeTime.escape_time(job)
        end)
      end
    end
  end

  @spec escape_time(Enumerable.t(), Job.t()) :: Complex.complex()
  def escape_time(stream, job) do
    stream
    |> Stream.with_index()
    |> Stream.drop_while(fn zi -> !done?(zi, job) end)
    |> Stream.take(1)
    |> Enum.to_list()
    |> List.first()
  end

  @spec pixels(Job.fractal_type(), list, Job.t()) :: t()
  def pixels(:mandelbrot, data, job) do
    Mandelbrot.pixels(data, job)
  end

  def pixels(:julia, data, job) do
    Julia.pixels(data, job)
  end

  def pixels(:burningship, data, job) do
    BurningShip.pixels(data, job)
  end
end
