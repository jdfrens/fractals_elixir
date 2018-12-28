defmodule LowLevelRGB16Test do
  @moduledoc """
  Inspired by https://github.com/yuce/png/blob/b6af0face98495f10fba3f638f1f36931ff2b3fe/examples/low_level_rgb_16.escript
  """

  use ExUnit.Case, async: true

  alias PNG.LowLevel

  import PNG.FileHelpers
  import PNG.ImageGenerationTestHelpers

  setup do
    setup_filenames("low_level_rgb_16.png")
  end

  test "generate a 16-bit RGB image", %{
    image_filename: image_filename,
    expected_filename: expected_filename
  } do
    size = {100, 100}
    png = %PNG{size: size, mode: {:rgb, 16}}
    rows = make_image(size, &pixel(size, &1, &2))

    [
      LowLevel.header(),
      LowLevel.chunk("IHDR", png),
      LowLevel.chunk("IDAT", {:rows, rows}),
      LowLevel.chunk("IEND")
    ]
    |> write_image_file(image_filename)

    {:ok, expected} = File.read(expected_filename)
    {:ok, actual} = File.read(image_filename)
    assert expected == actual
  end

  def pixel({width, height}, x, y) do
    r = trunc(x / width * 65_535)
    b = trunc(y / height * 65_535)
    <<r::16, 32_768::16, b::16>>
  end
end
