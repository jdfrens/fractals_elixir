defmodule Fractals.EscapeTime.Julia do
  @moduledoc """
  Implements the iterated function for a Julia set.
  """

  import Complex

  use Fractals.EscapeTime

  @impl Fractals.EscapeTime
  def iterate(grid_point, fractal) do
    Stream.iterate(grid_point, &iterator(&1, fractal.algorithm_params.c))
  end

  def iterator(z, c) do
    z |> square() |> add(c)
  end
end
