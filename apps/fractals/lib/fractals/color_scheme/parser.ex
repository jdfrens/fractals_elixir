defmodule Fractals.ColorScheme.Parser do
  @moduledoc """
  Parses a `Fractals.ColorScheme`.
  """

  alias Fractals.ColorScheme

  @spec parse(map()) :: map()
  def parse(params) do
    Enum.reduce(params, %ColorScheme{}, &parse_attribute/2)
  end

  defp parse_attribute({attribute, value}, color) do
    %{color | attribute => parse_value(attribute, value)}
  end

  defp parse_value(:type, value) do
    value
    |> Inflex.underscore()
    |> String.to_atom()
  end
end
