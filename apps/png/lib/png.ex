defmodule PNG do
  @moduledoc """
  Documentation for PNG.
  """

  alias PNG.{Config, LowLevel, ZLib}

  @spec create(map()) :: map()
  def create(%Config{file: file} = config) when is_pid(file) do
    callback = fn data -> :file.write(file, data) end

    config
    |> Map.put(:file, nil)
    |> Map.put(:callback, callback)
    |> create()
  end

  def create(%Config{} = config) do
    config
    |> append_header()
    |> append_palette()
    |> Map.put(:z, ZLib.open())
  end

  @spec append_header(Config.t()) :: Config.t()
  def append_header(%Config{callback: callback} = config) do
    :ok = callback.(LowLevel.header())
    :ok = callback.(LowLevel.chunk("IHDR", config))
    config
  end

  @spec append_palette(Config.t()) :: Config.t()
  def append_palette(%Config{palette: nil} = config) do
    config
  end

  def append_palette(%Config{callback: callback, palette: palette} = config) do
    :ok = callback.(LowLevel.chunk("PLTE", palette))
    config
  end

  @spec append(Config.t(), LowLevel.chunk()) :: Config.t()
  def append(config, {:row, row}) do
    append(config, {:data, [0, row]})
  end

  def append(config, {:rows, rows}) do
    f = fn row -> [0, row] end
    append(config, {:data, :lists.map(f, rows)})
  end

  def append(%Config{z: z} = config, {:data, raw_data}) do
    compressed = ZLib.deflate(z, raw_data)
    append(config, {:compressed, compressed})
    config
  end

  def append(config, {:compressed, []}) do
    config
  end

  def append(%Config{callback: callback} = config, {:compressed, compressed}) do
    chunks = LowLevel.chunk("IDAT", {:compressed, compressed})
    :ok = callback.(chunks)
    config
  end

  @spec close(PNG.Config.t()) :: :ok
  def close(%Config{z: z, callback: callback} = config) do
    compressed = ZLib.deflate(z, <<>>, :finish)
    append(config, {:compressed, List.flatten(compressed)})
    :ok = ZLib.close(z)
    :ok = callback.(LowLevel.chunk("IEND"))
    :ok
  end
end
