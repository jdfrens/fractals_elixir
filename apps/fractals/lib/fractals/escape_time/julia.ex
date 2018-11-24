defmodule Fractals.EscapeTime.Julia do
  @moduledoc """
  Implements the iterated function for a Julia set.
  """

  import Complex

  use Fractals.EscapeTime

  @behaviour Fractals.EscapeTime.Fractal

  @impl Fractals.EscapeTime.Fractal
  def parse_algorithm(params) do
    %Fractals.EscapeTime.Algorithm{
      type: :mandelbrot,
      module: __MODULE__,
      algorithm_params: %{c: Complex.parse(params[:c])}
    }
  end

  @impl Fractals.EscapeTime.Fractal
  def iterate(grid_point, algorithm) do
    Stream.iterate(grid_point, &iterator(&1, algorithm.c))
  end

  @impl Fractals.EscapeTime.Fractal
  def iterator(z, c) do
    z |> square |> add(c)
  end
end
