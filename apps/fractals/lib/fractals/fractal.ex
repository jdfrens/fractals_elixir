defmodule Fractals.Fractal do
  @moduledoc """
  Struct for representing an algorithm.
  """

  @type t :: %__MODULE__{
          type: atom(),
          module: module(),
          max_iterations: integer(),
          cutoff_squared: float(),
          algorithm_params: map()
        }

  @type complex_grid :: [Complex.complex()]

  defstruct type: nil,
            module: nil,
            max_iterations: 256,
            cutoff_squared: 4.0,
            algorithm_params: %{}

  @callback parse(keyword | map) :: t()

  @callback generate([Complex.complex()], t()) :: complex_grid()
end
