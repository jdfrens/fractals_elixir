defmodule Fractals.EscapeTime.Fractal do
  @moduledoc """
  Behaviour for escape-time algorithms.
  """

  @callback parse_algorithm(keyword()) :: Fractals.EscapeTime.Algorithm.t()

  @callback iterate(Complex.complex(), Fractals.Job.t()) :: Enumerable.t()

  @callback iterator(Complex.complex(), Complex.complex()) :: Complex.complex()
end
