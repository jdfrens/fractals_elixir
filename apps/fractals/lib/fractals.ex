defmodule Fractals do
  @moduledoc """
  The application.
  """

  alias Fractals.{Params, Reporters.Broadcaster}

  @unimplemented Application.get_env(:fractals, :unimplemented)

  @spec fractalize(Fractals.Params.t(), module()) :: :ok
  def fractalize(params, engine) do
    if unimplemented?(params.fractal) do
      Broadcaster.report(:skipping, params, reason: "fractal not implemented", from: self())
    else
      Broadcaster.report(:starting, params, from: self())

      with :ok <- engine.generate(params) do
        :ok
      else
        {:error, reason} ->
          Broadcaster.report(:skipping, params, reason: reason, from: self())
      end
    end

    :ok
  end

  @spec unimplemented?(Params.fractal_type()) :: boolean
  defp unimplemented?(fractal) do
    Enum.member?(@unimplemented, fractal)
  end
end
