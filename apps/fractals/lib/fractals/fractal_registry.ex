defmodule Fractals.FractalRegistry do
  @moduledoc """
  Keeps track of all of the fractals; used by `Fractals.Job` to populate the `:fractal` attribute.

  The application that implements a fractal should add the parser to the registry.  We have this in
  `Fractals.Application`:

  ```elixir
  Fractals.FractalRegistry.add(Fractals.Mandelbrot)
  ```

  The module send to `add/1` should implement the `Fractals.Fractal` behaviour.
  """

  use Agent

  @name Fractals.FractalRegistry

  @doc """
  Starts the registry.
  """
  @spec start_link(any()) :: GenServer.on_start()
  def start_link(initial_fractals) do
    Agent.start_link(
      fn -> Enum.into(initial_fractals, %{}) end,
      name: @name
    )
  end

  def add(identifier, fractal) do
    Agent.update(@name, &Map.put(&1, identifier, fractal))
  end

  def get(identifier) do
    Agent.get(@name, &Map.get(&1, identifier))
  end
end
