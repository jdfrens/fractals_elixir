defmodule Fractals.Output do
  @moduledoc """
  The functions needed to be a output.
  """

  @type t :: map()

  alias Fractals.Job
  alias Fractals.Output.ImageFile

  @callback start_file(job :: Job.t()) :: Job.t()

  @callback write_pixels(job :: Job.t(), pixels :: ImageFile.pixels()) :: Job.t()
end
