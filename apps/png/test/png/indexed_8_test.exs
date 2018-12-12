defmodule Indexed8Test do
  @moduledoc """
  Inspired by https://github.com/yuce/png/blob/b6af0face98495f10fba3f638f1f36931ff2b3fe/examples/indexed_8.escript
  """

  use ExUnit.Case, async: true

  @image_filename "test/images/indexed_8.png"
  @expected_filename "test/expected_outputs/indexed_8.png"

  setup do
    if File.exists?(@image_filename) do
      File.rm(@image_filename)
    else
      :ok
    end
  end

  test "generate an 8-bit indexed image" do
    width = 100
    height = 100
    palette = {:rgb, 8, [{255, 0, 0}, {0, 255, 0}, {0, 0, 255}]}
    {:ok, file} = :file.open(@image_filename, [:write])

    png =
      PNG.create(%{
        size: {width, height},
        mode: {:indexed, 8},
        palette: palette,
        file: file
      })

    :ok = append_rows(png)
    :ok = PNG.close(png)
    :ok = :file.close(file)

    {:ok, expected} = File.read(@expected_filename)
    {:ok, actual} = File.read(@image_filename)
    assert expected == actual
  end

  def append_rows(png) do
    append_row(png, 0)
  end

  def append_row(%{size: {_, height}}, height) do
    :ok
  end

  def append_row(%{size: {width, _}} = png, y) do
    thickness = div(width, 4)

    f = fn
      x when x > y + thickness -> 2
      x when x + thickness < y -> 1
      _ -> 0
    end

    row = :lists.map(f, :lists.seq(1, width))
    PNG.append(png, {:row, row})
    append_row(png, y + 1)
  end
end
