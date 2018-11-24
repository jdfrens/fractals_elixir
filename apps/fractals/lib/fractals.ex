defmodule Fractals do
  @moduledoc """
  The application.
  """

  alias Fractals.Job

  @unimplemented Application.get_env(:fractals, :unimplemented)

  @spec fractalize(Fractals.Job.t()) :: :ok | {:error, String.t()}
  def fractalize(job) do
    if unimplemented?(job.fractal) do
      {:error, "fractal not implemented"}
    else
      job.engine.module.generate(job)
    end
  end

  @spec unimplemented?(Job.fractal_type()) :: boolean
  defp unimplemented?(fractal) do
    Enum.member?(@unimplemented, fractal)
  end
end
