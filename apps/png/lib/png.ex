defmodule PNG do
  @moduledoc """
  Documentation for PNG.
  """

  @type chunk :: {:compressed, list()}

  @doc """
  Returns the header for a PNG file.
  """
  @spec header :: binary()
  def header do
    <<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A>>
  end

  @spec chunk(String.t(), chunk()) :: binary()
  # chunk('IHDR', #png_config{size = {Width, Height},
  #                           mode = {ColorType, BitDepth}}) ->
  #     % We only support basic compression, filter and interlace methods
  #     CompressionMethod = 0,
  #     FilterMethod = 0,
  #     InterlaceMethod = 0,
  #     ColorTypeByte = case ColorType of
  #                         grayscale -> 0;
  #                         rgb -> 2;
  #                         indexed -> 3;
  #                         grayscale_alpha -> 4;
  #                         rgba -> 6 end,
  #     Data = <<Width:32,
  #              Height:32,
  #              BitDepth:8,
  #              ColorTypeByte:8,
  #              CompressionMethod:8,
  #              FilterMethod:8,
  #              InterlaceMethod:8>>,
  #     chunk(<<"IHDR">>, Data);

  # chunk('IDAT', {rows, Rows}) ->
  #     % We don't currently support any scanline filters (other than None)
  #     Raw = list_to_binary([[?SCANLINE_FILTER, Row] || Row <- Rows]),
  #     chunk('IDAT', {raw, Raw});

  # chunk('IDAT', {raw, Data}) ->
  #     chunk('IDAT', {compressed, compress(Data)});

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
end
