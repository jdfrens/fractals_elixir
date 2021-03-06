defmodule LowLevelIndexed8Test do
  @moduledoc """
  Inspired by https://github.com/yuce/png/blob/b6af0face98495f10fba3f638f1f36931ff2b3fe/examples/low_level_indexed_8.escript
  """

  use ExUnit.Case, async: true

  import PNG.FileHelpers
  import PNG.ImageGenerationTestHelpers

  alias PNG.LowLevel

  setup do
    setup_filenames("low_level_indexed_8.png")
  end

  test "generate an 8-bit indexed image", %{
    image_filename: image_filename,
    expected_filename: expected_filename
  } do
    {width, _} = size = {50, 50}
    png = %PNG{size: size, mode: {:indexed, 8}}
    palette = {:rgb, 8, [{255, 0, 0}, {0, 255, 0}, {0, 0, 255}]}
    thickness = div(width, 4)
    rows = make_image(size, &pixel(thickness, &1, &2))

    [
      LowLevel.header(),
      LowLevel.chunk("IHDR", png),
      LowLevel.chunk("PLTE", palette),
      LowLevel.chunk("IDAT", {:rows, rows}),
      LowLevel.chunk("IEND")
    ]
    |> write_image_file(image_filename)

    {:ok, expected} = File.read(expected_filename)
    {:ok, actual} = File.read(image_filename)
    assert expected == actual
  end

  @spec pixel(non_neg_integer(), float(), float()) :: non_neg_integer()
  def pixel(thickness, x, y) do
    cond do
      x > y + thickness -> 2
      x + thickness < y -> 1
      true -> 0
    end
  end
end
