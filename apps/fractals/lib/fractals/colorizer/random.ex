defmodule Fractals.Colorizer.Random do
  @moduledoc """
  GenServer that generates and maintains an array of colors.  The same list of colors is used for all fractals until
  this process is killed and a new list is generated.
  """

  use GenServer

  import Fractals.EscapeTime.Helpers

  alias Fractals.Job

  ## Client

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @spec at(pid | atom, integer, Job.t()) :: PPM.color()
  def at(pid, iterations, job) do
    GenServer.call(pid, {:at, iterations, job})
  end

  ## Server

  @impl GenServer
  def init(:ok) do
    {:ok, make_colors()}
  end

  @impl GenServer
  def handle_call({:at, iterations, job}, _, colors) do
    color = colors |> pick_color(iterations, job) |> PPM.ppm()
    {:reply, color, colors}
  end

  ## Helpers

  @max_colors 2048

  @spec pick_color([[float]], integer, Job.t()) :: [integer]
  def pick_color(colors, iterations, job) do
    if inside?(iterations, job.fractal.max_iterations) do
      [0, 0, 0]
    else
      colors
      |> Enum.at(iterations)
      |> Enum.map(&round(&1 * job.image.max_intensity))
    end
  end

  @spec make_colors :: [[float]]
  defp make_colors do
    Stream.repeatedly(&random_color/0) |> Enum.take(@max_colors)
  end

  @spec random_color :: [float]
  defp random_color do
    [:rand.uniform(), :rand.uniform(), :rand.uniform()]
  end
end
