defmodule Fractals.Fractal do
  @moduledoc """
  Struct for representing an algorithm along with a basic behaviour for generating the fractal.
  """

  @type t :: %__MODULE__{
          type: atom(),
          module: module(),
          max_iterations: integer(),
          cutoff_squared: float(),
          algorithm_params: map()
        }

  @type complex_grid :: [Complex.t()]

  defstruct type: nil,
            module: nil,
            max_iterations: 256,
            cutoff_squared: 4.0,
            algorithm_params: %{}

  @callback generate([Complex.t()], t()) :: complex_grid()
end
