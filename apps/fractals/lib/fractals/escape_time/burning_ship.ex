defmodule Fractals.EscapeTime.BurningShip do
  @moduledoc """
  Kind of an awesome fractal.  It looks a bit like a burning ship.
  """

  use Fractals.EscapeTime

  import Complex

  @impl Fractals.EscapeTime
  def iterate(grid_point, _algorithm) do
    Stream.iterate(Complex.new(0.0), &iterator(&1, grid_point))
  end

  @spec iterator(Complex.complex(), Complex.complex()) :: Complex.complex()
  def iterator(z, c) do
    z |> burn |> square |> add(c)
  end

  @spec burn(Complex.complex()) :: Complex.complex()
  def burn(%Complex{re: real, im: imag}) do
    Complex.new(Kernel.abs(real), -1 * Kernel.abs(imag))
  end
end
