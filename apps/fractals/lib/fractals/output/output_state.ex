defmodule Fractals.Output.OutputState do
  @moduledoc """
  Keeps track of the next chunk that needs to be output.  Chunks that cannot be output yet are kept in a cache.
  """

  @type t :: %__MODULE__{
          next_number: non_neg_integer(),
          pid: pid() | nil,
          cache: map(),
          next_stage: (Fractals.Job.t() -> :ok)
        }

  defstruct next_number: 0, pid: nil, cache: %{}, next_stage: nil
end
