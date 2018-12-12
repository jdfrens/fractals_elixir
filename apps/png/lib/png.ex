defmodule PNG do
  @moduledoc """
  Documentation for PNG.
  """

  alias PNG.Config

  @type chunk ::
          {:raw, iodata()}
          | {:row, iodata()}
          | {:rows, iodata()}
          | {:data, iodata()}
          | {:compressed, iodata()}

  @scanline_filter 0

  @spec create(map()) :: map()
  def create(%{file: file} = png) do
    callback = fn data -> :file.write(file, data) end
    png = png |> Map.delete(:file) |> Map.put(:call, callback)
    create(png)
  end

  def create(%{size: {width, height} = size, mode: mode, call: callback} = png) do
    config = %Config{size: {width, height}, mode: mode}
    :ok = callback.(header())
    :ok = callback.(chunk("IHDR", config))
    :ok = append_palette(png)
    z = :zlib.open()
    :ok = :zlib.deflateInit(z)
    %{size: size, mode: mode, call: callback, z: z}
  end

  def append_palette(%{call: callback, palette: palette}) do
    chunk = chunk("PLTE", palette)
    :ok = callback.(chunk)
  end

  def append_palette(%{}) do
    :ok
  end

  @spec append(map(), chunk()) :: map()
  def append(png, {:row, row}) do
    append(png, {:data, [0, row]})
  end

  def append(png, {:rows, rows}) do
    f = fn row -> [0, row] end
    append(png, {:data, :lists.map(f, rows)})
  end

  def append(%{z: z} = png, {:data, raw_data}) do
    compressed = :zlib.deflate(z, raw_data)
    append(png, {:compressed, compressed})
    png
  end

  def append(png, {:compressed, []}) do
    png
  end

  def append(%{call: callback} = png, {:compressed, compressed}) do
    chunks = chunk("IDAT", {:compressed, compressed})
    :ok = callback.(chunks)
    png
  end

  @spec close(map) :: :ok
  def close(%{z: z, call: callback} = png) do
    compressed = :zlib.deflate(z, <<>>, :finish)
    append(png, {:compressed, List.flatten(compressed)})
    :ok = :zlib.deflateEnd(z)
    :ok = :zlib.close(z)
    :ok = callback.(chunk("IEND"))
    :ok
  end

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
      |> Enum.map(fn {r, g, b} ->
        <<r::size(bit_depth), g::size(bit_depth), b::size(bit_depth)>>
      end)
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
end
