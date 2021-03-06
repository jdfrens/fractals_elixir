defmodule Fractals do
  @moduledoc """
  The application.
  """

  @spec fractalize(Fractals.Job.t()) :: :ok | {:error, String.t()}
  def fractalize(job) do
    if unimplemented?(job.fractal) do
      {:error, "fractal #{job.fractal.type} not implemented"}
    else
      job.engine.module.generate(job)
    end
  end

  @spec unimplemented?(atom()) :: boolean
  defp unimplemented?(fractal) do
    fractal.module == Fractals.UnimplementedFractal
  end
end
