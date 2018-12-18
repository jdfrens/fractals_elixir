defmodule Fractals.FractalParser do
  @moduledoc """
  Behaviour for a parser for the `:fractal` portion of a `Fractals.Job`.
  """

  @doc """
  Parses the params as a `Fractals.Fractal`.
  """
  @callback parse(params :: keyword | map) :: Fractals.Fractal.t()
end
