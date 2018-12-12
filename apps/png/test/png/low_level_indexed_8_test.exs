defmodule LowLevelIndexed8Test do
  @moduledoc """
  Inspired by https://github.com/yuce/png/blob/b6af0face98495f10fba3f638f1f36931ff2b3fe/examples/low_level_indexed_8.escript
  """

  use ExUnit.Case, async: true

  import PNG.FileHelpers
  import PNG.LowLevelTestHelpers

  alias PNG.Config

  setup do
    setup_filenames("low_level_indexed_8.png")
  end

  test "generate an 8-bit indexed image", %{
    image_filename: image_filename,
    expected_filename: expected_filename
  } do
    {width, _} = size = {50, 50}
    config = %Config{size: size, mode: {:indexed, 8}}
    palette = {:rgb, 8, [{255, 0, 0}, {0, 255, 0}, {0, 0, 255}]}
    thickness = div(width, 4)
    rows = make_rows(size, &pixel(thickness, &1, &2))

    [
      PNG.header(),
      PNG.chunk("IHDR", config),
      PNG.chunk("PLTE", palette),
      PNG.chunk("IDAT", {:rows, rows}),
      PNG.chunk("IEND")
    ]
    |> write_image(image_filename)

    {:ok, expected} = File.read(expected_filename)
    {:ok, actual} = File.read(image_filename)
    assert expected == actual
  end

  def pixel(thickness, x, y) do
    cond do
      x > y + thickness -> 2
      x + thickness < y -> 1
      true -> 0
    end
  end
end
