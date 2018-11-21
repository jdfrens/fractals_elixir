defmodule Fractals.Engines.DoNothingParams do
  @moduledoc """
  The engine does nothing, but we've got things to parameterize and parse.
  """

  use Fractals.Behaviours.EngineParamsParser

  @type t :: %__MODULE__{
          type: :blue_picture,
          module: Fractals.Engines.DoNothing,
          params_parser: Fractals.Engines.DoNothingParams
        }

  defstruct type: :blue_picture,
            module: Fractals.Engines.DoNothing,
            params_parser: Fractals.Engines.DoNothingParams

  @impl Fractals.Behaviours.EngineParamsParser
  def parse(_raw_params) do
    %__MODULE__{}
  end
end
