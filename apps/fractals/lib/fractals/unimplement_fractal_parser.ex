defmodule Fractals.UnimplementedFractalParser do
  @moduledoc """
  Parser for an `Fractals.UnimplementedFractal`.
  """

  @behaviour Fractals.FractalParser

  @impl Fractals.FractalParser
  def parse(params) do
    %Fractals.Fractal{
      type: params[:type] |> String.downcase() |> String.to_atom(),
      module: Fractals.UnimplementedFractal
    }
  end
end
