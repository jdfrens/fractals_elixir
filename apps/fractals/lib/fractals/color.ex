defmodule Fractals.Color do
  @moduledoc """
  Representation of the coloring scheme that should be used for the image.
  """

  @type t :: %__MODULE__{
          type: atom() | nil,
          module: module(),
          max_intensity: integer() | nil
        }

  defstruct type: nil, module: Fractals.Colorizer, max_intensity: 255

  alias Fractals.Color

  def parse(params) do
    Enum.reduce(params, %Color{}, &parse_attribute/2)
  end

  defp parse_attribute({attribute, value}, color) do
    %{color | attribute => parse_value(attribute, value)}
  end

  defp parse_value(:type, value) do
    value
    |> Inflex.underscore()
    |> String.to_atom()
  end

  defp parse_value(:max_intensity, value) do
    value
  end
end
