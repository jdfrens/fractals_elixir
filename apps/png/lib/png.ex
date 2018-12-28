defmodule PNG do
  @moduledoc """
  Documentation for PNG.
  """

  alias PNG.{LowLevel, ZLib}

  @type size :: {pos_integer(), pos_integer()}
  @type mode :: {atom(), pos_integer()}
  @type bit_depth :: 8 | 16
  @type rgb_tuple :: {
          red :: pos_integer(),
          green :: pos_integer(),
          blue :: pos_integer()
        }
  @type rgba_tuple :: {
          red :: pos_integer(),
          green :: pos_integer(),
          blue :: pos_integer(),
          alpha :: pos_integer()
        }
  @type color_tuples :: list(rgb_tuple) | list(rgba_tuple)
  @type palette :: {:rgb, bit_depth, color_tuples}
  @type t :: %__MODULE__{
          size: size(),
          mode: mode(),
          palette: palette() | nil,
          compression_method: 0,
          filter_method: 0,
          interlace_method: 0,
          file: pid(),
          z: PNG.ZLib.zstream() | nil
        }

  defstruct size: {0, 0},
            mode: {:grayscale, 8},
            palette: nil,
            compression_method: 0,
            filter_method: 0,
            interlace_method: 0,
            file: nil,
            z: nil

  @type chunk ::
          {:row, iodata()}
          | {:rows, iodata()}
          | {:data, iodata()}
          | {:compressed, iodata()}

  @doc """
  Open resources for writing a PNG image.

  `png.file` must already be opened.  This opens a `ZLib` process for deflating the rows.
  """
  @spec open(PNG.t()) :: PNG.t()
  def open(%PNG{} = png) do
    Map.put(png, :z, ZLib.open())
  end

  @spec write_header(PNG.t()) :: PNG.t()
  def write_header(%PNG{file: file} = png) do
    :ok = :file.write(file, LowLevel.header())
    :ok = :file.write(file, LowLevel.chunk("IHDR", png))
    png
  end

  @spec write_palette(PNG.t()) :: PNG.t()
  def write_palette(%PNG{palette: nil} = png) do
    png
  end

  def write_palette(%PNG{file: file, palette: palette} = png) do
    :ok = :file.write(file, LowLevel.chunk("PLTE", palette))
    png
  end

  @spec write(PNG.t(), chunk()) :: PNG.t()
  def write(png, {:row, row}) do
    write(png, {:data, [0, row]})
  end

  def write(png, {:rows, rows}) do
    f = fn row -> [0, row] end
    write(png, {:data, :lists.map(f, rows)})
  end

  def write(%PNG{z: z} = png, {:data, raw_data}) do
    compressed = ZLib.deflate(z, raw_data)
    write(png, {:compressed, compressed})
    png
  end

  def write(png, {:compressed, []}) do
    png
  end

  def write(%PNG{file: file} = png, {:compressed, compressed}) do
    chunks = LowLevel.chunk("IDAT", {:compressed, compressed})
    :ok = :file.write(file, chunks)
    png
  end

  @spec close(PNG.t()) :: :ok
  def close(%PNG{z: z, file: file} = png) do
    compressed = ZLib.deflate(z, <<>>, :finish)
    write(png, {:compressed, List.flatten(compressed)})
    :ok = ZLib.close(z)
    :ok = :file.write(file, LowLevel.chunk("IEND"))
    :ok
  end
end
