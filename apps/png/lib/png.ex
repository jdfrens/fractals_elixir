defmodule PNG do
  @moduledoc """
  Documentation for PNG.
  """

  @doc """
  Returns the header for a PNG file.
  """
  @spec header :: binary()
  def header do
    <<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A>>
  end

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

  # chunk('IDAT', {compressed, CompressedData}) when is_list(CompressedData) ->
  def chunk("IDAT", {:compressed, compressed_data}) when is_list(compressed_data) do
    #     F = fun(Part) ->
    #         chunk(<<"IDAT">>, Part) end,
    #     lists:map(F, CompressedData);
    Enum.map(compressed_data, fn part ->
      chunk(<<"IDAT">>, part)
    end)
  end

  # chunk('PLTE', {rgb, BitDepth, ColorTuples}) ->
  #     L = [<<R:BitDepth, G:BitDepth, B:BitDepth>> || {R, G, B} <- ColorTuples],
  #     chunk(<<"PLTE">>, list_to_binary(L));

  # chunk(Type, Data) when is_binary(Type),
  #                        is_binary(Data) ->
  def chunk(type, data) when is_binary(type) and is_binary(data) do
    #     Length = byte_size(Data),
    length = byte_size(data)
    #     TypeData = <<Type/binary, Data/binary>>,
    type_data = <<type::binary, data::binary>>
    #     Crc = erlang:crc32(TypeData),
    crc = :erlang.crc32(type_data)
    #     <<Length:32, TypeData/binary, Crc:32>>.
    <<length::32, type_data::binary, crc::32>>
  end

  # chunk('IEND') ->
  #     chunk(<<"IEND">>, <<>>).
end
