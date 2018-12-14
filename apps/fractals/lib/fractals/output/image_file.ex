defmodule Fractals.Output.ImageFile do
  @moduledoc """
  Behaviour for writing image files.
  """

  @type pixel :: String.t()
  @type pixels :: [pixel()]

  @doc """
  Writes an entire file.

  All of the pixels must be provided; the image file is open, written, and closed.
  """
  @callback write_file(job :: Fractals.Job.t(), pixels :: pixels()) :: :ok

  @doc """
  Starts to write a file.

  This will write the header for the image, possibly palettes.  Pixels should be written using `write_pixels/2`
  """
  @callback start_file(job :: Fractals.Job.t()) :: :ok

  @doc """
  Writes pixels to a file that has been opened with `start_file/1`.
  """
  @callback write_pixels(job :: Fractals.Job.t(), pixels :: pixels()) :: :ok
end
