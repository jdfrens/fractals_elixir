defmodule PNG.LowLevelTest do
  @moduledoc """
  Transliteration of https://github.com/yuce/png/blob/b6af0face98495f10fba3f638f1f36931ff2b3fe/test/png_low_level_tests.erl
  """

  use ExUnit.Case, async: true

  import PNG.Consts

  alias PNG.Config

  # -module(png_low_level_tests).

  # -include_lib("eunit/include/eunit.hrl").
  # -include_lib("png/include/png.hrl").

  # low_level_test_() ->
  #     [fun get_header/0,
  #      fun 'IHDR_width_height'/0,
  #      fun 'IHDR_width_height_bit_depth'/0,
  #      fun 'IHDR_width_height_bit_depth_color_type'/0,
  #      fun compressed_IDAT/0,
  #      fun raw_IDAT/0,
  #      fun rows_IDAT/0,
  #      fun 'PLTE'/0].

  describe "header/0" do
    test "returns static content" do
      result = PNG.header()
      target = <<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A>>
      assert target == result
    end
  end

  test "IHDR with height" do
    result = PNG.chunk("IHDR", %Config{size: {32, 16}})

    target =
      <<0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 32, 0, 0, 0, 16, 8, 0, 0, 0, 0, 82, 107, 34, 133>>

    assert target == result
  end

  test "IHDR width height bit depth" do
    result = PNG.chunk("IHDR", %Config{size: {32, 16}, mode: const(:png_grayscale_8)})

    target =
      <<0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 32, 0, 0, 0, 16, 8, 0, 0, 0, 0, 82, 107, 34, 133>>

    assert target == result
  end

  test "IHDR width height bit depth color type" do
    result = PNG.chunk("IHDR", %Config{size: {32, 16}, mode: const(:png_rgb_8)})

    target =
      <<0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 32, 0, 0, 0, 16, 8, 2, 0, 0, 0, 248, 98, 234, 14>>

    assert target == result
  end

  test "compressed IDAT" do
    data = [<<0, 1, 2, 3>>]
    result = PNG.chunk("IDAT", {:compressed, data})
    target = [<<0, 0, 0, 4, 73, 68, 65, 84, 0, 1, 2, 3, 64, 222, 190, 8>>]
    assert target == result
  end

  test "raw IDAT" do
    data = <<0, 1, 2, 3>>
    result = PNG.chunk("IDAT", {:raw, data})

    target = [
      <<0, 0, 0, 12, 73, 68, 65, 84, 120, 156, 99, 96, 100, 98, 6, 0, 0, 14, 0, 7, 215, 111, 228,
        120>>
    ]

    assert target == result
  end

  test "rows IDAT" do
    data = [<<1, 2, 3>>]
    result = PNG.chunk("IDAT", {:rows, data})

    target = [
      <<0, 0, 0, 12, 73, 68, 65, 84, 120, 156, 99, 96, 100, 98, 6, 0, 0, 14, 0, 7, 215, 111, 228,
        120>>
    ]

    assert target == result
  end

  test "PLTE" do
    result = PNG.chunk("PLTE", {:rgb, 8, [{255, 0, 0}, {0, 0, 255}]})
    target = <<0, 0, 0, 6, 80, 76, 84, 69, 255, 0, 0, 0, 0, 255, 108, 161, 253, 142>>
    assert target == result
  end
end
