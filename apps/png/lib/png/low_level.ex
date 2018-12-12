defmodule PNG.LowLevel do
  alias PNG.Config

  @type chunk ::
          {:raw, iodata()}
          | {:row, iodata()}
          | {:rows, iodata()}
          | {:data, iodata()}
          | {:compressed, iodata()}

  @type color_tuple :: {integer(), integer(), integer()}

  @scanline_filter 0

  @doc """
  Returns the header for a PNG file.
  """
  @spec header :: binary()
  def header do
    <<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A>>
  end

  @doc """
  Low-level function to generate a chunk of the PNG content.

  This supports only basic compression, filter, and interlace methods.
  Only supports scanline filter 0 (i.e., none).
  """
  @spec chunk(String.t(), Config.t() | chunk() | binary()) :: binary()
  def chunk(type, data \\ <<>>)

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
    data = <<
      width::32,
      height::32,
      bit_depth::8,
      color_type_byte(color_type)::8,
      config.compression_method::8,
      config.filter_method::8,
      config.interlace_method::8
    >>

    chunk(<<"IHDR">>, data)
  end

  def chunk("IDAT", {:rows, rows}) do
    raw = :erlang.list_to_binary(for row <- rows, do: [@scanline_filter, row])
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

  def chunk("PLTE", {:rgb, bit_depth, color_tuples}) do
    data =
      color_tuples
      |> Enum.map(&color_tuple_to_binary(&1, bit_depth))
      |> :erlang.list_to_binary()

    chunk("PLTE", data)
  end

  def chunk(type, data) when is_binary(type) and is_binary(data) do
    length = byte_size(data)
    type_data = <<type::binary, data::binary>>
    crc = :erlang.crc32(type_data)
    <<length::32, type_data::binary, crc::32>>
  end

  @spec compress(binary()) :: [binary()]
  def compress(data) do
    with z = :zlib.open(),
         :ok <- :zlib.deflateInit(z),
         compressed = :zlib.deflate(z, data, :finish),
         :ok <- :zlib.deflateEnd(z),
         :ok <- :zlib.close(z) do
      List.flatten(compressed)
    end
  end

  @spec color_type_byte(atom()) :: integer()
  defp color_type_byte(:grayscale), do: 0
  defp color_type_byte(:rgb), do: 2
  defp color_type_byte(:indexed), do: 3
  defp color_type_byte(:grayscale_alpha), do: 4
  defp color_type_byte(:rgba), do: 6

  @spec color_tuple_to_binary(color_tuple(), integer()) :: binary()
  defp color_tuple_to_binary({r, g, b}, bit_depth) do
    <<r::size(bit_depth), g::size(bit_depth), b::size(bit_depth)>>
  end
end
