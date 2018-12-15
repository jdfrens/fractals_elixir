defmodule Fractals.EscapeTime.BurningShipParser do
  @moduledoc """
  Parses a config for the burning ship fractal.
  """

  @behaviour Fractals.FractalParser

  @impl Fractals.FractalParser
  def parse(_params) do
    %Fractals.Fractal{
      type: :burning_ship,
      module: Fractals.EscapeTime.BurningShip
    }
  end
end
