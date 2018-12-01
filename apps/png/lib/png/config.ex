defmodule PNG.Config do
  @moduledoc """
  Configuration for a PNG image.
  """

  import PNG.Consts

  alias PNG.Config

  # Transliteration from https://github.com/yuce/png/blob/b6af0face98495f10fba3f638f1f36931ff2b3fe/include/png.hrl#L12-L16
  # -record(png_config, {size = {0, 0},
  #                    mode = ?PNG_GRAYSCALE_8,
  #                    compression_method = 0,
  #                    filter_method = 0,
  #                    interlace_method = 0}).
  defstruct size: {0, 0},
            mode: const(:png_grayscale_8),
            compression_method: 0,
            filter_method: 0,
            interlace_method: 0

  # transliteration of https://github.com/yuce/png/blob/b6af0face98495f10fba3f638f1f36931ff2b3fe/src/png.erl#L106-L117
  # check_config(#png_config{size = {Width, Height}})
  #             when Width < 1 orelse Height < 1 ->
  # {error, invalid};
  def check(%{size: {width, height}}) when width < 1 or height < 1 do
    {:error, :invalid}
  end

  # check_config(#png_config{mode = Mode,
  #                      compression_method = 0,
  #                      filter_method = 0,
  #                      interlace_method = 0}) ->
  # valid_mode(Mode);
  def check(%Config{
        mode: mode,
        compression_method: 0,
        filter_method: 0,
        interlace_method: 0
      }) do
    valid_mode(mode)
  end

  # check_config(_) ->
  #   {error, not_supported}.
  def check(_config) do
    {:error, :not_supported}
  end

  # transliteration of https://github.com/yuce/png/blob/b6af0face98495f10fba3f638f1f36931ff2b3fe/src/png.erl#L79-L100
  @valid_color_types ~w(grayscale grayscale_alpha indexed rgb rgba)a
  @valid_bits [1, 2, 4, 8, 16]

  # valid_mode({ColorType, _}) when ColorType /= grayscale,
  #   ColorType /= grayscale_alpha,
  #   ColorType /= indexed,
  #   ColorType /= rgb,
  #   ColorType /= rgba ->
  # {error, invalid};
  def valid_mode({color_type, _}) when not (color_type in @valid_color_types),
    do: {:error, :invalid}

  # valid_mode({_, Bits}) when Bits /= 1,
  # Bits /= 2,
  # Bits /= 4,
  # Bits /= 8,
  # Bits /= 16 ->
  # {error, invalid};
  def valid_mode({_, bits}) when not (bits in @valid_bits),
    do: {:error, :invalid}

  # valid_mode({_, 8}) ->
  # ok;
  def valid_mode({_, 8}), do: :ok

  # valid_mode({indexed, 16}) ->
  # {error, invalid};
  def valid_mode({:indexed, 16}), do: {:error, :invalid}

  # valid_mode({_, 16}) ->
  # ok;
  def valid_mode({_, 16}), do: :ok

  # valid_mode({_, _}) ->
  # {error, unsupported}.
  def valid_mode({_, _}), do: {:error, :unsupported}
end
