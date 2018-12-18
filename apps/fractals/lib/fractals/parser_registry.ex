defmodule Fractals.ParserRegistry do
  @moduledoc """
  Keeps track of all of the parsers for `Fractals.Job`.

  Parsers for fractals, engines, and output can be registered, and `Fractals.Job` will use these parsers to part the
  corresponding part of the `Job` struct.

  The application that implements the parser should add the parser to the registry.  Register using tagged typles like so:

  ```elixir
  Fractals.ParserRegistry.add(:fractal, "mandelbrot", Fractals.Mandelbrot)
  Fractals.ParserRegistry.add(:engine, "stage_engine", StageEngine)
  Fractals.ParserRegistry.add(:output, Output)
  ```

  # FIXME: this is a smell!!!  One behaviour to rule them all!
  A `:fractal` module should implement the `Fractals.Fractal` behaviour.  An `:engine` module should implement the
  `Fractals.Engine`.  `Output` should just exist (eventually in its own component app.)
  """

  use Agent

  @type key_type :: atom()

  @name Fractals.ParserRegistry

  @doc """
  Starts the registry.
  """
  @spec start_link(any()) :: GenServer.on_start()
  def start_link(initial_parsers) do
    Agent.start_link(
      fn -> Enum.into(initial_parsers, %{}) end,
      name: @name
    )
  end

  @spec add(key_type(), atom(), module()) :: :ok
  def add(type, identifier, parser) do
    Agent.update(@name, &Map.put(&1, {type, identifier}, parser))
  end

  @spec get(key_type(), atom()) :: module()
  def get(type, identifier) do
    Agent.get(@name, fn map ->
      Map.get_lazy(map, {type, identifier}, fn ->
        Map.get(map, {type, :_})
      end)
    end)
  end
end
