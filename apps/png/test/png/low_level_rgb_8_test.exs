defmodule LogLevelRGB8Test do
  @moduledoc """
  Inspired by https://github.com/yuce/png/blob/b6af0face98495f10fba3f638f1f36931ff2b3fe/examples/low_level_rgb_8.escript
  """

  use ExUnit.Case, async: true

  alias PNG.Config

  @image_filename "test/images/low_level_rgb_8.png"
  @expected_filename "test/expected_outputs/low_level_rgb_8.png"

  setup do
    if File.exists?(@image_filename) do
      File.rm(@image_filename)
    else
      :ok
    end
  end

  test "generate an 8-bit RGB image" do
    width = 100
    height = 100
    png_config = %Config{size: {width, height}, mode: {:rgb, 8}}

    iodata = [
      PNG.header(),
      PNG.chunk("IHDR", png_config),
      PNG.chunk("IDAT", {:rows, make_rows(width, height)}),
      PNG.chunk("IEND")
    ]

    :ok = :file.write_file(@image_filename, iodata)

    {:ok, expected} = File.read(@expected_filename)
    {:ok, actual} = File.read(@image_filename)
    assert expected == actual
  end

  def make_rows(width, height) do
    f = fn y ->
      make_row(y, width, height)
    end

    :lists.map(f, :lists.seq(1, height))
  end

  def make_row(y, width, height) do
    f = fn x ->
      r = trunc(x / width * 255)
      b = trunc(y / height * 255)
      <<r, 128, b>>
    end

    :lists.map(f, :lists.seq(1, width))
  end
end
