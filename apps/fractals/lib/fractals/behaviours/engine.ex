defmodule Fractals.Behaviours.Engine do
  @moduledoc """
  The functions needed to be an engine.
  """

  @callback generate(Fractals.Params.t()) :: :ok
end
