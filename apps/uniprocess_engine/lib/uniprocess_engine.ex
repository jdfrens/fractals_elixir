defmodule UniprocessEngine do
  @moduledoc """
  Documentation for UniprocessEngine.
  """

  @behaviour Fractals.Behaviours.Engine

  @impl Fractals.Behaviours.Engine
  defdelegate generate(params), to: UniprocessEngine.Algorithm
end
