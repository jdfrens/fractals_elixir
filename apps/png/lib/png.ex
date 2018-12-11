defmodule PNG do
  @moduledoc """
  Documentation for PNG.
  """

  import PNG.Consts

  alias PNG.Config

  @type chunk :: {:compressed, list()}

  @doc """
  Returns the header for a PNG file.
  """
  @spec header :: binary()
  def header do
    <<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A>>
  end

  @doc """
  blah blah blah

  This supports only basic compression, filter, and interlace methods.
  Only supports scanline filter 0 (i.e., none).
  """
  @spec chunk(String.t(), chunk()) :: binary()
  def chunk(
        "IHDR",
        %Config{
          size: {width, height},
          mode: {color_type, bit_depth},
          compression_method: 0,
          filter_method: 0,
          interlace_method: 0
        } = config
      ) do
    color_byte_type =
      case color_type do
        :grayscale -> 0
        :rgb -> 2
        :indexed -> 3
        :grayscale_alpha -> 4
        :rgba -> 6
      end

    data = <<
      width::32,
      height::32,
      bit_depth::8,
      color_byte_type::8,
      config.compression_method::8,
      config.filter_method::8,
      config.interlace_method::8
    >>

    chunk(<<"IHDR">>, data)
  end

  def chunk("IDAT", {:rows, rows}) do
    raw = :erlang.list_to_binary(for row <- rows, do: [const(:scanline_filter), row])
    chunk("IDAT", {:raw, raw})
  end

  def chunk("IDAT", {:raw, data}) do
    chunk("IDAT", {:compressed, compress(data)})
  end

  def chunk("IDAT", {:compressed, compressed_data}) when is_list(compressed_data) do
    Enum.map(compressed_data, fn part ->
      chunk(<<"IDAT">>, part)
    end)
  end

  # chunk('PLTE', {rgb, BitDepth, ColorTuples}) ->
  #     L = [<<R:BitDepth, G:BitDepth, B:BitDepth>> || {R, G, B} <- ColorTuples],
  #     chunk(<<"PLTE">>, list_to_binary(L));

  def chunk(type, data) when is_binary(type) and is_binary(data) do
    length = byte_size(data)
    type_data = <<type::binary, data::binary>>
    crc = :erlang.crc32(type_data)
    <<length::32, type_data::binary, crc::32>>
  end

  # chunk('IEND') ->
  #     chunk(<<"IEND">>, <<>>).

  @spec compress(binary()) :: [binary()]
  def compress(data) do
    with z = :zlib.open(),
         :ok <- :zlib.deflateInit(z),
         compressed = :zlib.deflate(z, data, :finish),
         :ok <- :zlib.deflateEnd(z),
         :ok <- :zlib.close(z) do
      compressed
    end
  end
end
