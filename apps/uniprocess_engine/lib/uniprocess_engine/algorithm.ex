defmodule UniprocessEngine.Algorithm do
  @moduledoc """
  The straight, sequential algorithm to generate fractals.
  """

  alias Fractals.{
    Colorizer,
    Grid,
    Job,
    Reporters.Broadcaster
  }

  @spec generate(Job.t()) :: :ok
  def generate(job) do
    {job, nil}
    |> grid()
    |> fractal()
    |> colors()
    |> write()
    |> done()

    :ok
  end

  @spec grid({Job.t(), nil}) :: {Job.t(), Grid.t()}
  def grid({job, nil}) do
    {job, Grid.grid(job)}
  end

  @spec fractal({Job.t(), Grid.t()}) :: {Job.t(), Fractals.Fractal.complex_grid()}
  def fractal({job, grid}) do
    {job, job.fractal.module.generate(grid, job.fractal)}
  end

  @spec colors({Job.t(), Fractals.Fractal.complex_grid()}) :: {Job.t(), [PPM.color()]}
  def colors({job, pixels}) do
    {job, Enum.map(pixels, &Colorizer.color_point(&1, job))}
  end

  @spec write({Job.t(), [PPM.color()]}) :: {Job.t(), nil}
  def write({job, colors}) do
    job.output.module.write_file(job, colors)
    Job.close(job)
    {job, nil}
  end

  @spec done({Job.t(), nil}) :: {Job.t(), nil}
  def done({job, nil}) do
    Broadcaster.report(:done, job, from: self())
    {job, nil}
  end
end
