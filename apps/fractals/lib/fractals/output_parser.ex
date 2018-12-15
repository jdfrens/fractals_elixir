defmodule Fractals.OutputParser do
  @moduledoc """
  Behaviour for parsing the `:output` part of a `Fractals.Job`.
  """

  @doc """
  Parses params into a module that implements `Output`.
  """
  @callback parse(params :: map()) :: Fractals.Output.t()

  @doc """
  Called after all values are parsed.
  """
  @callback compute(job :: Job.t()) :: Fractals.Output.t()
end
