defmodule Fractals.EscapeTime.BurningShip do
  @moduledoc """
  Kind of an awesome fractal.  It looks a bit like a burning ship.
  """

  use Fractals.EscapeTime

  import Complex

  @behaviour Fractals.EscapeTime.Fractal

  @impl Fractals.EscapeTime.Fractal
  def parse_algorithm(_params) do
    %Fractals.EscapeTime.Algorithm{
      type: :mandelbrot,
      module: __MODULE__
    }
  end

  @impl Fractals.EscapeTime.Fractal
  def iterate(grid_point, _algorithm) do
    Stream.iterate(Complex.new(0.0), &iterator(&1, grid_point))
  end

  @impl Fractals.EscapeTime.Fractal
  def iterator(z, c) do
    z |> burn |> square |> add(c)
  end

  @spec burn(Complex.complex()) :: Complex.complex()
  def burn(%Complex{re: real, im: imag}) do
    Complex.new(Kernel.abs(real), -1 * Kernel.abs(imag))
  end
end
