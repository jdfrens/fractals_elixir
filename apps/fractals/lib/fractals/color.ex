defmodule Fractals.Color do
  @moduledoc """
  Representation of the coloring scheme that should be used for the image.
  """

  @typedoc """
  Color types.
  """
  @type t :: rgb() | rgba()

  @typedoc """
  Red-green-blue values between 0.0 and 1.0.
  """
  @type rgb :: {:rgb, float(), float(), float()}

  @typedoc """
  Red-green-blue values between 0.0 and 1.0.
  """
  @type rgb_int :: {:rgb_int, integer(), integer(), integer(), integer()}

  @typedoc """
  RGB representation with an alpha channel for transparency.
  """
  @type rgba :: {:rgba, float(), float(), float(), float()}

  @doc """
  Produces an RGB color by name.
  """
  @spec rgb(atom()) :: rgb()
  def rgb(:black), do: {:rgb, 0.0, 0.0, 0.0}
  def rgb(:white), do: {:rgb, 1.0, 1.0, 1.0}

  @doc """
  Produces an RGB color with each of the three color components.
  """
  @spec rgb(float(), float(), float()) :: rgb()
  def rgb(r, g, b), do: {:rgb, r, g, b}

  @doc """
  Scales an `t:rgb()` to an integer representation scales to a max intensity (i.e., `t:rgb_int()`).
  """
  @spec rgb_int(rgb(), pos_integer()) :: rgb_int()
  def rgb_int({:rgb, red, green, blue}, max_intensity) do
    {
      :rgb_int,
      float_to_integer(red, max_intensity),
      float_to_integer(green, max_intensity),
      float_to_integer(blue, max_intensity),
      max_intensity
    }
  end

  @spec float_to_integer(float(), pos_integer()) :: pos_integer()
  defp float_to_integer(float_intensity, max_intensity) do
    round(max_intensity * float_intensity)
  end
end
