defmodule RGB8Test do
  @moduledoc """
  Inspired by https://github.com/yuce/png/blob/b6af0face98495f10fba3f638f1f36931ff2b3fe/examples/rgb_8.escript
  """

  use ExUnit.Case, async: true

  import PNG.FileHelpers
  import PNG.ImageGenerationTestHelpers

  setup do
    setup_filenames("rgb_8.png")
  end

  test "generate an 8-bit rgb image", %{
    image_filename: image_filename,
    expected_filename: expected_filename
  } do
    size = {100, 100}
    mode = {:rgb, 8}
    {:ok, file} = :file.open(image_filename, [:write])

    png =
      %PNG{size: size, mode: mode, file: file}
      |> PNG.open()
      |> PNG.write_header()
      |> PNG.write_palette()

    :ok = write_image(png, &pixel/3)
    :ok = PNG.close(png)
    :ok = :file.close(file)

    {:ok, expected} = File.read(expected_filename)
    {:ok, actual} = File.read(image_filename)
    assert expected == actual
  end

  @spec pixel({pos_integer(), pos_integer()}, float(), float()) :: binary()
  def pixel({width, height}, x, y) do
    r = trunc(x / width * 255)
    b = trunc(y / height * 255)
    <<r, 128, b>>
  end
end
