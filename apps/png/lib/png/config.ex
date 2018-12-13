defmodule PNG.Config do
  @moduledoc """
  Configuration for a PNG image.
  """

  alias PNG.Config

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
          file: String.t() | nil,
          callback: (iodata() -> any()) | nil,
          z: PNG.ZLib.zstream() | nil
        }
  @type error :: {:error, :invalid} | {:error, :unsupported}

  defstruct size: {0, 0},
            mode: {:grayscale, 8},
            palette: nil,
            compression_method: 0,
            filter_method: 0,
            interlace_method: 0,
            file: nil,
            callback: nil,
            z: nil

  @doc """
  Basic check for a config.
  """
  @spec check(t()) :: :ok | error()
  def check(%Config{size: {width, height}}) when width < 1 or height < 1 do
    {:error, :invalid}
  end

  def check(%Config{
        mode: mode,
        compression_method: 0,
        filter_method: 0,
        interlace_method: 0
      }) do
    valid_mode(mode)
  end

  def check(_config) do
    {:error, :not_supported}
  end

  @valid_color_types ~w(grayscale grayscale_alpha indexed rgb rgba)a
  @valid_bits [1, 2, 4, 8, 16]

  @spec valid_mode({atom(), pos_integer()}) :: :ok | error()
  defp valid_mode({color_type, _}) when not (color_type in @valid_color_types),
    do: {:error, :invalid}

  defp valid_mode({_, bits}) when not (bits in @valid_bits),
    do: {:error, :invalid}

  defp valid_mode({_, 8}), do: :ok

  defp valid_mode({:indexed, 16}), do: {:error, :invalid}

  defp valid_mode({_, 16}), do: :ok

  defp valid_mode({_, _}), do: {:error, :unsupported}
end
