defmodule Fractals.EscapeTime.MandelbrotParser do
  @moduledoc """
  Parses the config for the Mandelbrot fractal.
  """

  @behaviour Fractals.FractalParser

  @impl Fractals.FractalParser
  def parse(_params) do
    %Fractals.Fractal{
      type: :mandelbrot,
      module: Fractals.EscapeTime.Mandelbrot
    }
  end
end
