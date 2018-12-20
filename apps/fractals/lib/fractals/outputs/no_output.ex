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
  def start(_job), do: nil

  @impl Fractals.Output
  def write(job, _output_state, _pixels), do: job

  @impl Fractals.OutputParser
  def parse(_params), do: %__MODULE__{}

  @impl Fractals.OutputParser
  def compute(_job), do: %__MODULE__{}
end
