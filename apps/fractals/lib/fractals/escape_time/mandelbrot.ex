defmodule Fractals.EscapeTime.Mandelbrot do
  @moduledoc """
  Implements the iterated function for the Mandelbrot set.
  """

  use Fractals.EscapeTime

  import Complex

  @zero Complex.new(0.0, 0.0)

  @impl Fractals.EscapeTime
  def iterate(grid_point, _algorithm) do
    Stream.iterate(@zero, &iterator(&1, grid_point))
  end

  @spec iterator(Complex.complex(), Complex.complex()) :: Complex.complex()
  def iterator(z, c) do
    z |> square |> add(c)
  end
end
