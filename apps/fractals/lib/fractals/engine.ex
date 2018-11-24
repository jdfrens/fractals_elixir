defmodule Fractals.Engine do
  @moduledoc """
  The functions needed to be an engine.
  """

  @type t :: map()

  @doc "Parses params into a module that implements `Fractals.Engine`."
  @callback parse_engine(params :: map) :: t()

  @doc "Called after all values are parsed"
  @callback compute_parsed(Fractals.Job.t()) :: Fractals.Job.t()

  @callback generate(Fractals.Job.t()) :: :ok | {:error, String.t()}

  defmacro __using__(_opts) do
    quote do
      @behaviour Fractals.Engine

      @impl Fractals.Engine
      def compute_parsed(params) do
        params
      end

      defoverridable compute_parsed: 1
    end
  end
end
