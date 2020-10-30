defmodule PNG.ImageGenerationTestHelpers do
  @moduledoc """
  Helpers for the low-level tests.
  """

  @doc """
  Generates the data for rows to be put into an image using the low-level functions.

  `f` needs to be a function that receives `x` (column) and `y` (row).
  """
  @spec make_image({non_neg_integer(), non_neg_integer()}, (non_neg_integer(), non_neg_integer -> binary())) :: list()
  def make_image({width, height}, f) do
    Enum.map(1..height, fn y ->
      Enum.map(1..width, fn x ->
        f.(x, y)
      end)
    end)
  end

  @doc """
  Writes data for the image as specified by `f`.
  """
  @spec write_image(
          map(),
          ({non_neg_integer(), non_neg_integer()}, non_neg_integer, non_neg_integer -> binary())
        ) :: any()
  def write_image(%{size: {width, height} = size} = png, f) do
    Enum.each(1..height, fn y ->
      row =
        Enum.map(1..width, fn x ->
          f.(size, x, y)
        end)

      PNG.write(png, {:row, row})
    end)
  end
end
