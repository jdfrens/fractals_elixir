defmodule Fractals.Engines.DoNothing do
  @moduledoc """
  Returns an error because no engine was specified.
  """

  @behaviour Fractals.Behaviours.Engine

  @impl Fractals.Behaviours.Engine
  def generate(_params) do
    {:error, "no engine was specified"}
  end
end
