defmodule UniprocessEngine.Algorithm do
  @moduledoc """
  The straight, sequential algorithm to generate fractals.
  """

  alias Fractals.{
    Colorizer,
    EscapeTime,
    Grid,
    ImageMagick,
    Job,
    Output.PPMFile,
    Reporters.Broadcaster
  }

  @spec generate(Job.t()) :: :ok
  def generate(job) do
    {job, nil}
    |> grid()
    |> pixels()
    |> colors()
    |> write()
    |> convert()
    |> done()

    :ok
  end

  @spec grid({Job.t(), nil}) :: {Job.t(), Grid.t()}
  def grid({job, nil}) do
    {job, Grid.grid(job)}
  end

  @spec pixels({Job.t(), Grid.t()}) :: {Job.t(), EscapeTime.t()}
  def pixels({job, grid}) do
    {job, EscapeTime.pixels(job.fractal, grid, job)}
  end

  @spec colors({Job.t(), EscapeTime.t()}) :: {Job.t(), [PPM.color()]}
  def colors({job, pixels}) do
    {job, Enum.map(pixels, &Colorizer.color_point(&1, job))}
  end

  @spec write({Job.t(), [PPM.color()]}) :: {Job.t(), nil}
  def write({job, colors}) do
    PPMFile.write_file(job, colors)
    Job.close(job)
    {job, nil}
  end

  @spec convert({Job.t(), nil}) :: {Job.t(), nil}
  def convert({job, nil}) do
    job.output_filename
    |> Path.extname()
    |> convert_to(job)

    {job, nil}
  end

  @spec done({Job.t(), nil}) :: {Job.t(), nil}
  def done({job, nil}) do
    Broadcaster.report(:done, job, from: self())
    {job, nil}
  end

  @spec convert_to(String.t(), Job.t()) :: Job.t()
  defp convert_to(".png", job) do
    root_filename =
      job.output_filename
      |> Path.rootname(".png")
      |> Path.rootname(".ppm")

    ppm_filename = root_filename <> ".ppm"
    ImageMagick.convert(ppm_filename, job.output_filename)

    job
  end
end
