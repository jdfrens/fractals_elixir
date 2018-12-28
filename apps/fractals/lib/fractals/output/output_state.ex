defmodule Fractals.Output.OutputState do
  @moduledoc """
  Keeps track of the next chunk that needs to be output.  Chunks that cannot be output yet are kept in a cache.
  """

  @type t :: %__MODULE__{
          job: Fractals.Job.t(),
          output_module: module(),
          max_intensity: non_neg_integer(),
          next_number: non_neg_integer(),
          pid: pid(),
          cache: map()
        }

  defstruct job: nil,
            output_module: nil,
            max_intensity: 255,
            next_number: 1,
            pid: nil,
            cache: %{}
end
