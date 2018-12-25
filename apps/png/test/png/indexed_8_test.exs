defmodule Indexed8Test do
  @moduledoc """
  Inspired by https://github.com/yuce/png/blob/b6af0face98495f10fba3f638f1f36931ff2b3fe/examples/indexed_8.escript
  """

  use ExUnit.Case, async: true

  import PNG.FileHelpers

  setup do
    setup_filenames("indexed_8.png")
  end

  test "generate an 8-bit indexed image", %{
    image_filename: image_filename,
    expected_filename: expected_filename
  } do
    size = {100, 100}
    mode = {:indexed, 8}
    palette = {:rgb, 8, [{255, 0, 0}, {0, 255, 0}, {0, 0, 255}]}
    {:ok, file} = :file.open(image_filename, [:write])

    png =
      %PNG{size: size, mode: mode, palette: palette, file: file}
      |> PNG.open()
      |> PNG.write_header()
      |> PNG.write_palette()

    :ok = write_rows(png)
    :ok = PNG.close(png)
    :ok = :file.close(file)

    {:ok, expected} = File.read(expected_filename)
    {:ok, actual} = File.read(image_filename)
    assert expected == actual
  end

  def write_rows(png) do
    write_row(png, 0)
  end

  def write_row(%{size: {_, height}}, height) do
    :ok
  end

  def write_row(%{size: {width, _}} = png, y) do
    thickness = div(width, 4)

    f = fn
      x when x > y + thickness -> 2
      x when x + thickness < y -> 1
      _ -> 0
    end

    row = :lists.map(f, :lists.seq(1, width))
    PNG.write(png, {:row, row})
    write_row(png, y + 1)
  end
end
