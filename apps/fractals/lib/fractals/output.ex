defmodule Fractals.Output do
  @moduledoc """
  The functions needed to be a output.
  """

  @type pixels :: [any()]

  alias Fractals.Job

  @doc """
  Starts the output for a fractal image.

  This could be opening a file and writing a header; it might be opening a window or Phoenix channel.
  """
  @callback start(job :: Job.t()) :: Job.t()

  @doc """
  Writes pixels to the output.
  """
  @callback write(job :: Job.t(), pixels :: pixels()) :: Job.t()
end
