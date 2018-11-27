defmodule Fractals.EscapeTime.Julia do
  @moduledoc """
  Implements the iterated function for a Julia set.
  """

  import Complex

  use Fractals.EscapeTime

  @impl Fractals.Fractal
  def parse(params) do
    %Fractals.Fractal{
      type: :julia,
      module: __MODULE__,
      algorithm_params: %{c: Complex.parse(params[:c])}
    }
  end

  @impl Fractals.EscapeTime
  def iterate(grid_point, algorithm) do
    Stream.iterate(grid_point, &iterator(&1, algorithm.c))
  end

  def iterator(z, c) do
    z |> square |> add(c)
  end
end
