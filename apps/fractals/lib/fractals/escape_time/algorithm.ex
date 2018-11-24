defmodule Fractals.EscapeTime.Algorithm do
  @moduledoc """
  Struct for representing an algorithm.
  """

  @type t :: %__MODULE__{
          type: :mandelbrot | :julia | :burning_ship,
          module: module(),
          algorithm_params: map()
        }

  defstruct type: nil, module: nil, algorithm_params: %{}
end
