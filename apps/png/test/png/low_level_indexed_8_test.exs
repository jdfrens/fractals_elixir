defmodule LowLevelIndexed8Test do
  @moduledoc """
  Inspired by https://github.com/yuce/png/blob/b6af0face98495f10fba3f638f1f36931ff2b3fe/examples/low_level_indexed_8.escript
  """

  use ExUnit.Case, async: true

  alias PNG.Config

  @image_filename "test/images/low_level_indexed_8.png"
  @expected_filename "test/expected_outputs/low_level_indexed_8.png"

  setup do
    if File.exists?(@image_filename) do
      File.rm(@image_filename)
    else
      :ok
    end
  end

  test "generate an image" do
    width = 50
    height = 50
    pallette = {:rgb, 8, [{255, 0, 0}, {0, 255, 0}, {0, 0, 255}]}
    rows = make_rows(width, height, pallette)
    data = {:rows, rows}
    png_config = %Config{size: {width, height}, mode: {:indexed, 8}}

    iodata = [
      PNG.header(),
      PNG.chunk("IHDR", png_config),
      PNG.chunk("PLTE", pallette),
      PNG.chunk("IDAT", data),
      PNG.chunk("IEND")
    ]

    :ok = :file.write_file(@image_filename, iodata)

    {:ok, expected} = File.read(@expected_filename)
    {:ok, actual} = File.read(@image_filename)
    assert expected == actual
  end

  def make_rows(width, height, {:rgb, _, colors}) do
    color_count = length(colors)

    f = fn y ->
      make_row(width, y, color_count, 2)
    end

    :lists.map(f, :lists.seq(1, height))
  end

  def make_row(width, y, _color_count, _pix_size) do
    thickness = div(width, 4)

    f = fn x ->
      cond do
        x > y + thickness -> 2
        x + thickness < y -> 1
        true -> 0
      end
    end

    :lists.map(f, :lists.seq(1, width))
  end
end
