defmodule Fractals.Output do
  @moduledoc """
  The functions needed to be a output.
  """

  @type t :: map()

  alias Fractals.Job
  alias Fractals.Output.ImageFile

  @callback start_file(job :: Job.t()) :: Job.t()

  @callback write_pixels(job :: Job.t(), pixels :: ImageFile.pixels()) :: Job.t()

  @doc "Parses params into a module that implements `Output`."
  @callback parse(params :: map()) :: t()

  @doc "Called after all values are parsed"
  @callback compute(job :: Job.t()) :: t()
end
