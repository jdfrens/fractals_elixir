defmodule PPM do
  @moduledoc """
  Helper functions for generating a PPM file---ASCII text to describe
  an image file.  Very verbose, of course, but easy to write and read.

  cf. https://en.wikipedia.org/wiki/Netpbm_format
  """

  alias Fractals.Color

  @type t :: String.t()

  @format "~3B ~3B ~3B "

  @spec black :: t()
  def black, do: ppm(0, 0, 0)
  @spec white :: t()
  def white, do: ppm(255, 255, 255)

  @spec p3_header(pos_integer, pos_integer) :: [String.t()]
  def p3_header(width, height) do
    [
      "P3",
      Integer.to_string(width),
      Integer.to_string(height),
      "255"
    ]
  end

  @spec ppm(Color.rgb_int()) :: t()
  def ppm({:rgb_int, red, green, blue, _max}) do
    ppm([red, green, blue])
  end

  @spec ppm(list(non_neg_integer())) :: t()
  def ppm(rgb) when is_list(rgb) do
    :erlang.iolist_to_binary(:io_lib.format(@format, rgb))
  end

  @spec ppm(non_neg_integer(), non_neg_integer(), non_neg_integer()) :: t()
  def ppm(red, green, blue), do: ppm([red, green, blue])
end
