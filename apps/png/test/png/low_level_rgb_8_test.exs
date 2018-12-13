defmodule LogLevelRGB8Test do
  @moduledoc """
  Inspired by https://github.com/yuce/png/blob/b6af0face98495f10fba3f638f1f36931ff2b3fe/examples/low_level_rgb_8.escript
  """

  use ExUnit.Case, async: true

  alias PNG.{Config, LowLevel}

  import PNG.FileHelpers
  import PNG.ImageGenerationTestHelpers

  setup do
    setup_filenames("low_level_rgb_8.png")
  end

  test "generate an 8-bit RGB image", %{
    image_filename: image_filename,
    expected_filename: expected_filename
  } do
    size = {100, 100}
    config = %Config{size: size, mode: {:rgb, 8}}
    rows = make_image(size, &pixel(size, &1, &2))

    [
      LowLevel.header(),
      LowLevel.chunk("IHDR", config),
      LowLevel.chunk("IDAT", {:rows, rows}),
      LowLevel.chunk("IEND")
    ]
    |> write_image(image_filename)

    {:ok, expected} = File.read(expected_filename)
    {:ok, actual} = File.read(image_filename)
    assert expected == actual
  end

  def pixel({width, height}, x, y) do
    r = trunc(x / width * 255)
    b = trunc(y / height * 255)
    <<r, 128, b>>
  end
end
