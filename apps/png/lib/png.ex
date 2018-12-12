defmodule PNG do
  @moduledoc """
  Documentation for PNG.
  """

  alias PNG.{Config, LowLevel}

  @spec create(map()) :: map()
  def create(%{file: file} = png) do
    callback = fn data -> :file.write(file, data) end
    png = png |> Map.delete(:file) |> Map.put(:call, callback)
    create(png)
  end

  def create(%{size: {width, height} = size, mode: mode, call: callback} = png) do
    config = %Config{size: {width, height}, mode: mode}
    :ok = callback.(LowLevel.header())
    :ok = callback.(LowLevel.chunk("IHDR", config))
    :ok = append_palette(png)
    z = :zlib.open()
    :ok = :zlib.deflateInit(z)
    %{size: size, mode: mode, call: callback, z: z}
  end

  def append_palette(%{call: callback, palette: palette}) do
    chunk = LowLevel.chunk("PLTE", palette)
    :ok = callback.(chunk)
  end

  def append_palette(%{}) do
    :ok
  end

  @spec append(map(), LowLevel.chunk()) :: map()
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
    chunks = LowLevel.chunk("IDAT", {:compressed, compressed})
    :ok = callback.(chunks)
    png
  end

  @spec close(map) :: :ok
  def close(%{z: z, call: callback} = png) do
    compressed = :zlib.deflate(z, <<>>, :finish)
    append(png, {:compressed, List.flatten(compressed)})
    :ok = :zlib.deflateEnd(z)
    :ok = :zlib.close(z)
    :ok = callback.(LowLevel.chunk("IEND"))
    :ok
  end
end
