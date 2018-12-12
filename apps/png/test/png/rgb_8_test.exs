defmodule RGB8Test do
  @moduledoc """
  Inspired by https://github.com/yuce/png/blob/b6af0face98495f10fba3f638f1f36931ff2b3fe/examples/rgb_8.escript
  """

  use ExUnit.Case, async: true

  @image_filename "test/images/rgb_8.png"
  @expected_filename "test/expected_outputs/rgb_8.png"

  setup do
    if File.exists?(@image_filename) do
      File.rm(@image_filename)
    else
      :ok
    end
  end

  test "generate an 8-bit rgb image" do
    width = 100
    height = 100
    {:ok, file} = :file.open(@image_filename, [:write])

    png =
      PNG.create(%{
        size: {width, height},
        mode: {:rgb, 8},
        file: file
      })

    :ok = append_rows(png)
    :ok = PNG.close(png)
    :ok = :file.close(file)

    {:ok, expected} = File.read(@expected_filename)
    {:ok, actual} = File.read(@image_filename)
    assert expected == actual
  end

  def append_rows(%{size: {_, height}} = png) do
    f = fn y -> append_row(png, y) end
    :lists.foreach(f, :lists.seq(1, height))
  end

  def append_row(%{size: {width, height}} = png, y) do
    f = fn x ->
      r = trunc(x / width * 255)
      b = trunc(y / height * 255)
      <<r, 128, b>>
    end

    row = :lists.map(f, :lists.seq(1, width))
    PNG.append(png, {:row, row})
  end
end
