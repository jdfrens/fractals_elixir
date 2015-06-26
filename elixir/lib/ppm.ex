defmodule PPM do

  @black :erlang.iolist_to_binary(:io_lib.format("~3B ~3B ~3B ", [  0,   0,   0]))
  @white :erlang.iolist_to_binary(:io_lib.format("~3B ~3B ~3B ", [255, 255, 255]))
  def black, do: @black
  def white, do: @white

  # TODO: blog about this
  def ppm(red, green, blue) do
    :erlang.iolist_to_binary(:io_lib.format("~3B ~3B ~3B ", [red, green, blue]))
  end

end