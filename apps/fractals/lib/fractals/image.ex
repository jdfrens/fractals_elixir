defmodule Fractals.Image do
  @moduledoc """
  Configuration for an image: size and corners.
  """

  alias Fractals.Image
  alias Fractals.Size

  @type t :: %__MODULE__{
          lower_right: Complex.complex() | nil,
          upper_left: Complex.complex() | nil,
          size: Size.t() | nil
        }

  defstruct lower_right: Complex.new(6.0, 5.0),
            size: %Size{width: 512, height: 384},
            upper_left: Complex.new(5.0, 6.0)

  @spec parse(map()) :: Image.t()
  def parse(params) do
    Enum.reduce(params, %Image{}, &parse_attribute/2)
  end

  defp parse_attribute({attribute, value}, image) do
    %{image | attribute => parse_value(attribute, value)}
  end

  defp parse_value(complex_attribute, value)
       when complex_attribute in [:lower_right, :upper_left] do
    Complex.parse(value)
  end

  defp parse_value(:size, value) do
    [_, width, height] = Regex.run(~r/(\d+)x(\d+)/, value)

    %Size{
      width: String.to_integer(width),
      height: String.to_integer(height)
    }
  end
end
