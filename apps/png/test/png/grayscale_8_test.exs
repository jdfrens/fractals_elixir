defmodule PNG.Grayscale8Test do
  @moduledoc """
  Inspired by https://github.com/yuce/png/blob/b6af0face98495f10fba3f638f1f36931ff2b3fe/examples/grayscale_8.escript.
  """

  use ExUnit.Case, async: true

  import PNG.FileHelpers
  import PNG.ImageGenerationTestHelpers

  setup do
    setup_filenames("grayscale_8.png")
  end

  test "write an 8-bit grayscale image", %{
    image_filename: image_filename,
    expected_filename: expected_filename
  } do
    size = {100, 100}
    mode = {:grayscale, 8}
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

  def pixel({width, height}, x, y) do
    g = trunc(255 * (x / width + y / height) / 2)
    <<g>>
  end
end
