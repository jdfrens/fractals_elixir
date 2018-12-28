defmodule Fractals.Outputs.NoOutput do
  @moduledoc """
  Default output which outputs nothing to nowhere.
  """

  @behaviour Fractals.Output
  @behaviour Fractals.OutputParser

  defstruct type: :no_output, module: __MODULE__

  @impl Fractals.Output
  def write_everything(job, _pixels), do: job

  @impl Fractals.Output
  def open(_job), do: nil

  @impl Fractals.Output
  def start(state), do: state

  @impl Fractals.Output
  def write(state, _pixels), do: state

  @impl Fractals.Output
  def stop(state), do: state

  @impl Fractals.Output
  def close(state), do: state

  @impl Fractals.OutputParser
  def parse(_params), do: %__MODULE__{}

  @impl Fractals.OutputParser
  def compute(_job), do: %__MODULE__{}
end
