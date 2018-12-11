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

  @tag :skip
  # 'IHDR_width_height'() ->
  test "IHDR with height" do
    #     Result = png:chunk('IHDR', #png_config{size = {32, 16}}),
    result = PNG.chunk("IHDR", PNG.config(size: {32, 16}))
    #     Target = <<0,0,0,13,73,72,68,82,0,0,0,
    #                32,0,0,0,16,8,0,0,0,0,82,107,34,133>>,
    target =
      <<0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 32, 0, 0, 0, 16, 8, 0, 0, 0, 0, 82, 107, 34, 133>>

    #     [?_assertEqual(Target, Result)].
    assert target == result
  end

  @tag :skip
  # 'IHDR_width_height_bit_depth'() ->
  test "IHDR width height bit depth" do
    #     Result = png:chunk('IHDR', #png_config{size = {32, 16},
    #                                        mode = ?PNG_GRAYSCALE_8}),
    result = PNG.chunk("IHDR", PNG.config(size: {32, 26}, mode: PNG_GRAYSCALE_8))
    #     Target = <<0,0,0,13,73,72,68,82,0,0,0,
    #                32,0,0,0,16,8,0,0,0,0,82,107,34,133>>,
    target =
      <<0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 32, 0, 0, 0, 16, 8, 0, 0, 0, 0, 82, 107, 34, 133>>

    #     [?_assertEqual(Target, Result)].
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

  # raw_IDAT() ->
  test "raw IDAT" do
    #     Data = <<0, 1, 2, 3>>,
    data = <<0, 1, 2, 3>>
    #     Result = png:chunk('IDAT', {raw, Data}),
    result = PNG.chunk("IDAT", {:raw, data})
    #     Target = [<<0,0,0,12,73,68,65,84,120,156,
    #                 99,96,100,98,6,0,0,14,0,7,215,111,228,120>>],
    target = [
      <<0, 0, 0, 12, 73, 68, 65, 84, 120, 156, 99, 96, 100, 98, 6, 0, 0, 14, 0, 7, 215, 111, 228,
        120>>
    ]

    #     [?_assertEqual(Target, Result)].
    assert target == result
  end

  @tag :skip
  # rows_IDAT() ->
  test "rows IDAT" do
    #     Data = [<<1, 2, 3>>],
    data = [<<1, 2, 3>>]
    #     Result = png:chunk('IDAT', {rows, Data}),
    result = PNG.chunk("IDAT", {:rows, data})
    #     Target = [<<0,0,0,12,73,68,65,84,120,156,
    #                 99,96,100,98,6,0,0,14,0,7,215,111,228,120>>],
    target = [
      <<0, 0, 0, 12, 73, 68, 65, 84, 120, 156, 99, 96, 100, 98, 6, 0, 0, 14, 0, 7, 215, 111, 228,
        120>>
    ]

    #     [?_assertEqual(Target, Result)].
    assert target == result
  end

  @tag :skip
  # 'PLTE'() ->
  test "PLTE" do
    #     Result = png:chunk('PLTE', {rgb, 8, [{255, 0, 0}, {0, 0, 255}]}),
    result = PNG.chunk("PLTE", {:rgb, 8, [{255, 0, 0}, {0, 0, 255}]})
    #     Target = <<0,0,0,6,80,76,84,69,255,0,0,0,0,255,108,161,253,142>>,
    target = <<0, 0, 0, 6, 80, 76, 84, 69, 255, 0, 0, 0, 0, 255, 108, 161, 253, 142>>
    #     [?_assertEqual(Target, Result)].
    assert target == result
  end
end
