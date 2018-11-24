defmodule Fractals.EscapeTime.Mandelbrot do
  @moduledoc """
  Implements the iterated function for the Mandelbrot set.
  """

  import Complex

  use Fractals.EscapeTime

  @behaviour Fractals.EscapeTime.Fractal

  @zero Complex.new(0.0, 0.0)

  @impl Fractals.EscapeTime.Fractal
  def parse_algorithm(_params) do
    %Fractals.EscapeTime.Algorithm{
      type: :mandelbrot,
      module: __MODULE__
    }
  end

  @impl Fractals.EscapeTime.Fractal
  def iterate(grid_point, _algorithm) do
    Stream.iterate(@zero, &iterator(&1, grid_point))
  end

  @impl Fractals.EscapeTime.Fractal
  def iterator(z, c) do
    z |> square |> add(c)
  end
end
