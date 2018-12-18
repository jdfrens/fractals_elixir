defmodule Fractals.EscapeTime.JuliaParser do
  @moduledoc """
  Parses a config for a Julia fractal.
  """

  @behaviour Fractals.FractalParser

  @impl Fractals.FractalParser
  def parse(params) do
    %Fractals.Fractal{
      type: :julia,
      module: Fractals.EscapeTime.Julia,
      algorithm_params: %{c: Complex.parse(params[:c])}
    }
  end
end
