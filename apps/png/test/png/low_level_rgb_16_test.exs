defmodule LowLevelRGB16Test do
  @moduledoc """
  Inspired by https://github.com/yuce/png/blob/b6af0face98495f10fba3f638f1f36931ff2b3fe/examples/low_level_rgb_16.escript
  """

  use ExUnit.Case, async: true

  alias PNG.Config

  @image_filename "test/images/low_level_rgb_16.png"
  @expected_filename "test/expected_outputs/low_level_rgb_16.png"

  setup do
    if File.exists?(@image_filename) do
      File.rm(@image_filename)
    else
      :ok
    end
  end

  test "generate a 16-bit RGB image" do
    width = 100
    height = 100
    rows = make_rows(width, height)
    data = {:rows, rows}
    png_config = %Config{size: {width, height}, mode: {:rgb, 16}}

    iodata = [
      PNG.header(),
      PNG.chunk("IHDR", png_config),
      PNG.chunk("IDAT", data),
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
      r = trunc(x / width * 65535)
      b = trunc(y / height * 65535)
      <<r::16, 32768::16, b::16>>
    end

    :lists.map(f, :lists.seq(1, width))
  end
end
