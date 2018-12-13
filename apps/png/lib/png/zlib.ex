defmodule PNG.ZLib do
  @moduledoc """
  Wrapper around `:zlib` for PNG generation.

  This wrapper is very opinionated for its using with the `png` app.
  """

  @type zstream :: :zlib.zstream()
  @type data :: iodata()
  @type compressed :: iolist()

  @doc """
  Completely compresses one binary, opening and closing the zlib interface.
  """
  @spec one_shot(data()) :: compressed()
  def one_shot(data) do
    with z = open(),
         compressed = deflate(z, data, :finish),
         :ok <- close(z) do
      List.flatten(compressed)
    end
  end

  @doc """
  Opens a zlib stream for deflating binaries.
  """
  def open do
    with z = :zlib.open(),
         :ok <- :zlib.deflateInit(z),
         do: z
  end

  @doc """
  Deflates a binary.
  """
  @spec deflate(zstream(), data()) :: compressed()
  def deflate(z, data) do
    :zlib.deflate(z, data)
  end

  @doc """
  Deflates a binary and finishes the stream.

  Call `close/1` after calling this.
  """
  @spec deflate(zstream(), data(), :finish) :: compressed()
  def deflate(z, data, :finish) do
    :zlib.deflate(z, data, :finish)
  end

  @doc """
  Closes a zlib stream.
  """
  @spec close(zstream()) :: :ok
  def close(z) do
    with :ok <- :zlib.deflateEnd(z), :ok <- :zlib.close(z), do: :ok
  end
end
