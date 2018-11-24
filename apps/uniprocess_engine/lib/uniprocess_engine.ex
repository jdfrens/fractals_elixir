defmodule UniprocessEngine do
  @moduledoc """
  Documentation for UniprocessEngine.
  """

  use Fractals.Engine

  @type t :: %__MODULE__{
          type: :uniprocess,
          module: UniprocessEngine
        }

  defstruct type: :uniprocess, module: UniprocessEngine

  @impl Fractals.Engine
  def parse_engine(_params) do
    %__MODULE__{}
  end

  @impl Fractals.Engine
  defdelegate generate(job), to: UniprocessEngine.Algorithm
end
