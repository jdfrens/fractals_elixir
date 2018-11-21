defmodule Fractals.EngineParamsParserRegistry do
  @moduledoc """
  Keeps track of all of the params parsers for engines; used by  `Fractals.Params` to fill in values for the `:engine` attribute.

  The application that implements an engine should add the parser to the registry:

  ```elixir
  Fractals.EngineRegistry.add(BluePicture.ParamsParser)
  ```

  where `BluePicture` is (probably) the name of an engine and `BluePicture.ParamsParser` is the name of the parser that
  implements the `Fractals.Behaviours.EngineParams` behaviour.
  """

  use Agent

  @name Fractals.EngineRegistry

  @doc """
  Starts the broker; `engines` is a list of initial engines.
  """
  @spec start_link(any()) :: GenServer.on_start()
  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: @name)
  end

  def add(identifier, engine) do
    Agent.update(@name, &Map.put(&1, identifier, engine))
  end

  def get(identifier) do
    Agent.get(@name, &Map.get(&1, identifier))
  end
end
