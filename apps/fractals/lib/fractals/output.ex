defmodule Fractals.Output do
  @moduledoc """
  The functions needed to be a output.
  """

  alias Fractals.Job
  alias Fractals.Output.OutputState

  @type t :: map()
  @type pixels :: [Fractals.Color.t()]

  defmacro __using__(_opts) do
    quote do
      @behaviour Fractals.Output

      alias Fractals.Output.OutputState

      @impl Fractals.Output
      def write_everything(job, pixels) do
        %{} =
          %OutputState{pid: open(job), job: job}
          |> start()
          |> write(pixels)
          |> stop()
          |> close()

        job
      end

      defoverridable write_everything: 2
    end
  end

  @doc """
  Starts, writes, and stops an entire output.
  """
  @callback write_everything(job :: Job.t(), pixels :: pixels()) :: Job.t()

  @doc """
  Opens up a medium for the image output.

  This might be opening a file; it might be starting up a window.
  """
  @callback open(job :: Job.t()) :: pid() | nil

  @doc """
  Starts the output for a fractal image.  Called after `open/1`.

  This might be writing a header; changing window settings.
  """
  @callback start(state :: OutputState.t()) :: OutputState.t()

  @doc """
  Writes pixels to the output.
  """
  @callback write(output_state :: OutputState.t(), pixels :: pixels()) :: OutputState.t()

  @doc """
  Finishes off the output.

  This might include writing a "footer" or some other kind of closing.
  """
  @callback stop(output_state :: OutputState.t()) :: OutputState.t()

  @doc """
  Closes up the output resource.

  This might include closing an output stream or finalizing a window (but _not_ closing it).
  """
  @callback close(output_state :: OutputState.t()) :: OutputState.t()
end
