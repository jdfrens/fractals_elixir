defmodule PNG.Consts do
  @moduledoc """
  Constants.

  Transliteration of https://github.com/yuce/png/blob/b6af0face98495f10fba3f638f1f36931ff2b3fe/include/png.hrl#L2-L10
  """

  # -define(PNG_INDEXED_8, {indexed, 8}).
  # -define(PNG_GRAYSCALE_8, {grayscale, 8}).
  # -define(PNG_GRAYSCALE_16, {grayscale, 16}).
  # -define(PNG_GRAYSCALE_ALPHA_8, {grayscale_alpha, 8}).
  # -define(PNG_GRAYSCALE_ALPHA_16, {grayscale_alpha, 16}).
  # -define(PNG_RGB_8, {rgb, 8}).
  # -define(PNG_RGB_16, {rgb, 16}).
  # -define(PNG_RGBA_8, {rgba, 8}).
  # -define(PNG_RGBA_16, {rgba, 16}).
  defmacro const(:png_indexed_8), do: {:indexed, 8}
  defmacro const(:png_grayscale_8), do: {:grayscale, 8}
  defmacro const(:png_grayscale_16), do: {:grayscale, 16}
  defmacro const(:png_grayscale_alpha_8), do: {:grayscale_alpha, 8}
  defmacro const(:png_grayscale_alpha_16), do: {:grayscale_alpha, 16}
  defmacro const(:png_rgb_8), do: {:rgb, 8}
  defmacro const(:png_rgb_16), do: {:rgb, 16}
  defmacro const(:png_rgba_8), do: {:rgba, 8}
  defmacro const(:png_rgba_16), do: {:rgba, 16}
end
