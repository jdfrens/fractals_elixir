defmodule Fractals.EngineParamsParserRegistry do
  @moduledoc """
  Keeps track of all of the params parsers for engines; used by  `Fractals.Params` to fill in values for the `:engine`
  attribute.

  The application that implements an engine should add the parser to the registry:

  ```elixir
  Fractals.EngineParamsParserRegistry.add(CoolEngine.Params)
  ```

  where `CoolEngine` is (probably) the name of an engine and `CoolEngine.Params` is the name of the params struct that
  also implements the `Fractals.Behaviours.EngineParams` behaviour.
  """

  use Agent

  @name Fractals.EngineParamsParserRegistry

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
