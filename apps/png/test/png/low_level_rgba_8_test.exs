defmodule LowLevelRGBa8Test do
  @moduledoc """
  Inspired by https://github.com/yuce/png/blob/b6af0face98495f10fba3f638f1f36931ff2b3fe/examples/low_level_rgba_8.escript
  """

  use ExUnit.Case, async: true

  alias PNG.Config

  import PNG.FileHelpers
  import PNG.LowLevelTestHelpers

  setup do
    setup_filenames("low_level_rgba_8.png")
  end

  test "generate an 8-bit rgba image", %{
    image_filename: image_filename,
    expected_filename: expected_filename
  } do
    size = {50, 50}
    config = %Config{size: size, mode: {:rgba, 8}}
    rows = make_rows(size, &pixel(size, &1, &2))

    [
      PNG.header(),
      PNG.chunk("IHDR", config),
      PNG.chunk("IDAT", {:rows, rows}),
      PNG.chunk("IEND")
    ]
    |> write_image(image_filename)

    {:ok, expected} = File.read(expected_filename)
    {:ok, actual} = File.read(image_filename)
    assert expected == actual
  end

  def pixel({width, height}, x, y) do
    r = trunc(x / width * 255)
    b = trunc(y / height * 255)
    a = trunc((x / width + y / height) / 2 * 255)
    <<r, 128, b, a>>
  end
end
