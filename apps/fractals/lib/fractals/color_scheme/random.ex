defmodule Fractals.ColorScheme.Random do
  @moduledoc """
  GenServer that generates and maintains an array of colors.  The same list of colors is used for all fractals until
  this process is killed and a new list is generated.
  """

  use GenServer

  import Fractals.EscapeTime.Helpers

  alias Fractals.{Color, Job}

  ## Client

  @spec start_link(any()) :: GenServer.on_start()
  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @spec at(pid() | atom(), integer(), Job.t()) :: Color.t()
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
    color = colors |> pick_color(iterations, job)

    {:reply, color, colors}
  end

  ## Helpers

  @max_colors 2048

  @spec pick_color([Color.rgb()], integer(), Job.t()) :: [Color.rgb()]
  def pick_color(colors, iterations, job) do
    if inside?(iterations, job.fractal.max_iterations) do
      Color.rgb(:black)
    else
      Enum.at(colors, iterations)
    end
  end

  @spec make_colors :: [Color.rgb()]
  defp make_colors do
    Stream.repeatedly(&random_color/0) |> Enum.take(@max_colors)
  end

  @spec random_color :: Color.rgb()
  defp random_color do
    Color.rgb(:rand.uniform(), :rand.uniform(), :rand.uniform())
  end
end
