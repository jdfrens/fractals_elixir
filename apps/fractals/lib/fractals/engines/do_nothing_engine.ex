defmodule Fractals.Engines.DoNothingEngine do
  @moduledoc """
  Returns an error because no engine was specified.
  """

  use Fractals.Engine

  @type t :: %__MODULE__{
          type: :do_nothing,
          module: __MODULE__
        }

  defstruct type: :do_nothing, module: __MODULE__

  @impl Fractals.Engine
  def parse_engine(_params) do
    %__MODULE__{}
  end

  @impl Fractals.Engine
  def generate(_job) do
    {:error, "no engine was specified"}
  end
end
