defmodule Fractals.EscapeTime.Julia do
  @moduledoc """
  Implements the iterated function for a Julia set.
  """

  use Fractals.EscapeTime

  import Complex

  @impl Fractals.EscapeTime
  def iterate(grid_point, fractal) do
    Stream.iterate(grid_point, &iterator(&1, fractal.algorithm_params.c))
  end

  @spec iterator(Complex.complex(), Complex.complex()) :: Complex.complex()
  def iterator(z, c) do
    z |> square |> add(c)
  end
end
