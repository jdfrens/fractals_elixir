defmodule PNG do
  @moduledoc """
  Documentation for PNG.
  """

  import PNG.Consts

  alias PNG.Config

  @type chunk :: {:compressed, list()}

  # -spec create(map()) -> map().
  @spec create(map()) :: map()

  # create(#{file := File} = Png) ->
  #     Callback = fun(Data) ->
  #                     file:write(File, Data) end,
  #     Png2 = maps:remove(file, Png#{call => Callback}),
  #     create(Png2);

  # create(#{size := {Width, Height} = Size,
  #          mode := Mode,
  #          call := Callback} = Png) ->
  def create(%{size: {width, height} = size, mode: mode, call: callback} = png) do
    #     Config = #png_config{size = {Width, Height},
    #                          mode = Mode},
    config = %Config{size: {width, height}, mode: mode}
    #     ok = Callback(header()),
    :ok = callback.(header())
    #     ok = Callback(chunk('IHDR', Config)),
    :ok = callback.(chunk("IHDR", config))
    #     ok = append_palette(Png),
    :ok = append_palette(png)
    #     Z = zlib:open(),
    z = :zlib.open()
    #     ok = zlib:deflateInit(Z),
    :ok = :zlib.deflateInit(z)
    #     #{size => Size,
    #       mode => Mode,
    #       call => Callback,
    #       z => Z}.
    %{size: size, mode: mode, call: callback, z: z}
  end

  #   append_palette(#{call := Callback, palette := Palette}) ->
  def append_palette(%{call: callback, palette: palette}) do
    #     Chunk = chunk('PLTE', Palette),
    chunk = chunk("PLTE", palette)
    #     ok = Callback(Chunk);
    :ok = callback.(chunk)
  end

  #   append_palette(#{}) ->
  def append_palette(%{}) do
    #     ok.
    :ok
  end

  # -spec append(map(), {row, iodata()} | {rows, iodata()} | {data, iodata()} |
  #                     {compressed, iodata()}) -> map().
  @spec append(
          map(),
          {:row, iodata()} | {:rows, iodata()} | {:data, iodata()} | {:compressed, iodata()}
        ) :: map()
  # append(Png, {row, Row}) ->
  def append(png, {:row, row}) do
    #     append(Png, {data, [0, Row]});
    append(png, {:data, [0, row]})
  end

  # append(Png, {rows, Rows}) ->
  def append(png, {:rows, rows}) do
    #     F = fun(Row) ->
    #         [0, Row] end,
    f = fn row -> [0, row] end
    #     append(Png, {data, lists:map(F, Rows)});
    append(png, {:data, :lists.map(f, rows)})
  end

  # append(#{z := Z} = Png, {data, RawData}) ->
  def append(%{z: z} = png, {:data, raw_data}) do
    #     Compressed = zlib:deflate(Z, RawData),
    compressed = :zlib.deflate(z, raw_data)
    #     append(Png, {compressed, Compressed}),
    append(png, {:compressed, compressed})
    #     Png;
    png
  end

  # append(Png, {compressed, []}) ->
  def append(png, {:compressed, []}) do
    #     Png;
    png
  end

  # append(#{call := Callback} = Png, {compressed, Compressed}) ->
  def append(%{call: callback} = png, {:compressed, compressed}) do
    #     Chunks = chunk('IDAT', {compressed, Compressed}),
    chunks = chunk("IDAT", {:compressed, compressed})
    #     ok = Callback(Chunks),
    :ok = callback.(chunks)
    #     Png.
    png
  end

  # -spec close(map()) -> ok.
  @spec close(map) :: :ok
  # close(#{z := Z, call := Callback} = Png) ->
  def close(%{z: z, call: callback} = png) do
    #     Compressed = zlib:deflate(Z, <<>>, finish),
    compressed = :zlib.deflate(z, <<>>, :finish)
    #     append(Png, {compressed, Compressed}),
    append(png, {:compressed, compressed})
    #     ok = zlib:deflateEnd(Z),
    :ok = :zlib.deflateEnd(z)
    #     ok = zlib:close(Z),
    :ok = :zlib.close(z)
    #     ok = Callback(chunk('IEND')),
    :ok = callback.(chunk("IEND"))
    #     ok.
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
  @spec chunk(String.t(), chunk()) :: binary()
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
      compressed
    end
  end
end
