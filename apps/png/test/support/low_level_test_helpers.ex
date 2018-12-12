defmodule PNG.LowLevelTestHelpers do
  @moduledoc """
  Helpers for the low-level tests.
  """

  @doc """
  Generates the data for rows to be put into an image.

  `f` needs to be a function that receives `x` (column) and `y` (row).
  """
  def make_rows({width, height}, f) do
    Enum.map(1..height, fn y ->
      Enum.map(1..width, fn x ->
        f.(x, y)
      end)
    end)
  end
end
