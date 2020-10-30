defmodule Fractals.Grid do
  @moduledoc """
  Generates a grid of x and y values which can be turned into
  complex numbers.
  """

  import Complex, only: :macros

  alias Fractals.{Chunk, Grid, Image, Job}

  @type t :: [Complex.complex()]

  @spec chunked_grid(Job.t()) :: [Chunk.t()]
  def chunked_grid(job) do
    job |> grid |> chunk(job)
  end

  @spec chunk(Grid.t(), Job.t()) :: [Chunk.t()]
  def chunk(grid, job) do
    grid
    |> Stream.chunk_every(job.engine.chunk_size, job.engine.chunk_size, [])
    |> Stream.zip(1..job.engine.chunk_count)
    |> Stream.map(fn {data, number} -> %Chunk{number: number, data: data, job: job} end)
    |> Enum.to_list()
  end

  @spec grid(Job.t()) :: Grid.t()
  def grid(job) do
    for y <- ys(job.image),
        x <- xs(job.image),
        do: Complex.new(x, y)
  end

  @spec xs(Image.t()) :: Enumerable.t()
  def xs(image) do
    %Image{
      size: %Fractals.Size{width: width},
      upper_left: %Complex{re: x0},
      lower_right: %Complex{re: x1}
    } = image

    float_sequence(width, x0, x1)
  end

  @spec ys(Image.t()) :: Enumerable.t()
  def ys(image) do
    %Image{
      size: %Fractals.Size{height: height},
      upper_left: %Complex{im: y1},
      lower_right: %Complex{im: y0}
    } = image

    float_sequence(height, y1, y0)
  end

  @spec float_sequence(non_neg_integer, float, float) :: Enumerable.t()
  def float_sequence(count, first, last) do
    delta = (last - first) / (count - 1)
    first |> Stream.iterate(&(&1 + delta)) |> Enum.take(count)
  end
end
