defmodule Fractals do
  @moduledoc """
  The application.
  """

  @spec fractalize(Fractals.Job.t()) :: :ok | {:error, String.t()}
  def fractalize(job) do
    if unimplemented?(job.fractal) do
      {:error, "fractal not implemented"}
    else
      job.engine.module.generate(job)
    end
  end

  @spec unimplemented?(atom()) :: boolean
  defp unimplemented?(fractal) do
    fractal.type == :unimplemented
  end
end
