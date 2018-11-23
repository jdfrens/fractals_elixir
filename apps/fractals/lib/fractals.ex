defmodule Fractals do
  @moduledoc """
  The application.
  """

  alias Fractals.Params

  @unimplemented Application.get_env(:fractals, :unimplemented)

  @spec fractalize(Fractals.Params.t()) :: :ok | {:error, String.t()}
  def fractalize(params) do
    if unimplemented?(params.fractal) do
      {:error, "fractal not implemented"}
    else
      params.engine.module.generate(params)
    end
  end

  @spec unimplemented?(Params.fractal_type()) :: boolean
  defp unimplemented?(fractal) do
    Enum.member?(@unimplemented, fractal)
  end
end
