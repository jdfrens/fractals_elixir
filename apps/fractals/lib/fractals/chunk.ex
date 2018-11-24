defmodule Fractals.Chunk do
  @moduledoc """
  Defines a chunk of work.
  """

  @type t :: %__MODULE__{
          number: integer,
          data: list,
          job: Fractals.Job.t()
        }

  defstruct number: nil, data: [], job: nil

  @doc """
  Computes the number of chunks based on the width and height of the image and the chunk size.

  If the chunk size evenly divides the area (width times height), then that quotient is the answer; if there's a
  remainder then we add one.
  """
  @spec chunk_count(integer(), integer(), integer()) :: integer()
  def chunk_count(width, height, chunk_size) do
    pixel_count = width * height
    div(pixel_count, chunk_size) + if rem(pixel_count, chunk_size) == 0, do: 0, else: 1
  end
end
