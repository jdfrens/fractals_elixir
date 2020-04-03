defmodule Fractals.EscapeTime do
  @moduledoc """
  Implements the basic escape-time algorithm for fractals.
  """

  import Fractals.EscapeTime.Helpers

  alias Fractals.EscapeTime

  defmacro __using__(_options) do
    quote do
      @behaviour Fractals.Fractal
      @behaviour Fractals.EscapeTime

      @impl Fractals.Fractal
      def generate(grid_points, fractal) do
        Enum.map(grid_points, fn grid_point ->
          grid_point
          |> fractal.module.iterate(fractal)
          |> EscapeTime.escape_time(fractal)
        end)
      end
    end
  end

  @spec escape_time(Enumerable.t(), Fractals.Fractal.t()) :: Complex.t()
  def escape_time(stream, fractal) do
    stream
    |> Stream.with_index()
    |> Stream.drop_while(fn zi -> !done?(zi, fractal) end)
    |> Stream.take(1)
    |> Enum.to_list()
    |> List.first()
  end

  @callback iterate(Complex.t(), Fractals.Job.t()) :: Enumerable.t()
end
