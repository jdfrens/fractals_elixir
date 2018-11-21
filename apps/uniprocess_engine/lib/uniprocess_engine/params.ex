defmodule UniprocessEngine.Params do
  @moduledoc """
  Params for the uniprocess engine; there's nothing in this except the basic fields.
  """

  use Fractals.Behaviours.EngineParamsParser

  @type t :: %__MODULE__{
          type: :uniprocess,
          module: UniprocessEngine,
          params_parser: UniprocessEngine.Params
        }

  defstruct type: :uniprocess, module: UniprocessEngine, params_parser: UniprocessEngine.Params

  @impl Fractals.Behaviours.EngineParamsParser
  def parse(_map) do
    %__MODULE__{}
  end
end
