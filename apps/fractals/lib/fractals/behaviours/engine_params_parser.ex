defmodule Fractals.Behaviours.EngineParamsParser do
  @moduledoc """
  Behaviour for engine params.
  """

  @type t :: map()

  @doc "Parses a map into the appropriate params for an engine."
  @callback parse(map) :: t()

  @doc "Called after all values are parsed"
  @callback compute(Fractals.Params.t()) :: Fractals.Params.t()

  defmacro __using__(_opts) do
    quote do
      @behaviour Fractals.Behaviours.EngineParamsParser

      @impl Fractals.Behaviours.EngineParamsParser
      def compute(params) do
        params
      end

      defoverridable compute: 1
    end
  end
end
