defmodule PNG.Grayscale8Test do
  @moduledoc """
  Inspired by https://github.com/yuce/png/blob/b6af0face98495f10fba3f638f1f36931ff2b3fe/examples/grayscale_8.escript.
  """

  use ExUnit.Case, async: true

  import PNG.FileHelpers

  setup do
    setup_filenames("grayscale_8.png")
  end

  test "write an 8-bit grayscale image", %{
    image_filename: image_filename,
    expected_filename: expected_filename
  } do
    width = 100
    height = 100
    {:ok, file} = :file.open(image_filename, [:write])
    png = PNG.create(%{size: {width, height}, mode: {:grayscale, 8}, file: file})
    :ok = append_rows(png)
    :ok = PNG.close(png)
    :ok = :file.close(file)

    {:ok, expected} = File.read(expected_filename)
    {:ok, actual} = File.read(image_filename)
    assert expected == actual
  end

  def append_rows(%{size: {_, height}} = png) do
    f = fn y -> append_row(png, y) end
    :lists.foreach(f, :lists.seq(1, height))
  end

  def append_row(%{size: {width, height}} = png, y) do
    f = fn x ->
      g = trunc(255 * (x / width + y / height) / 2)
      <<g>>
    end

    row = :lists.map(f, :lists.seq(1, width))
    PNG.append(png, {:row, row})
  end
end
