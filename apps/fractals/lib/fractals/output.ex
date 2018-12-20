defmodule Fractals.Output do
  @moduledoc """
  The functions needed to be a output.
  """

  @type t :: map()
  @type pixels :: [Fractals.Color.t()]

  alias Fractals.Job

  @doc """
  Starts, writes, and stops an entire output.
  """
  @callback write_everything(job :: Job.t(), pixels :: pixels()) :: Job.t()

  @doc """
  Starts the output for a fractal image.

  This could be opening a file and writing a header; it might be opening a window or Phoenix channel.
  """
  @callback start(job :: Job.t()) :: pid()

  @doc """
  Writes pixels to the output.
  """
  @callback write(job :: Job.t(), output_state :: map(), pixels :: pixels()) :: Job.t()
end
