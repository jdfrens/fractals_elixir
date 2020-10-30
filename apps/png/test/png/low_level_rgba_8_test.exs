defmodule LowLevelRGBa8Test do
  @moduledoc """
  Inspired by https://github.com/yuce/png/blob/b6af0face98495f10fba3f638f1f36931ff2b3fe/examples/low_level_rgba_8.escript
  """

  use ExUnit.Case, async: true

  import PNG.FileHelpers
  import PNG.ImageGenerationTestHelpers

  alias PNG.LowLevel

  setup do
    setup_filenames("low_level_rgba_8.png")
  end

  test "generate an 8-bit rgba image", %{
    image_filename: image_filename,
    expected_filename: expected_filename
  } do
    size = {50, 50}
    png = %PNG{size: size, mode: {:rgba, 8}}
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

  @spec pixel({pos_integer(), pos_integer()}, float(), float()) :: binary()
  def pixel({width, height}, x, y) do
    r = trunc(x / width * 255)
    b = trunc(y / height * 255)
    a = trunc((x / width + y / height) / 2 * 255)
    <<r, 128, b, a>>
  end
end
