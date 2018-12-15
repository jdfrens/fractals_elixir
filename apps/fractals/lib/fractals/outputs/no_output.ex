defmodule Fractals.Outputs.NoOutput do
  @moduledoc """
  Default output which outputs nothing to nowhere.
  """

  @behaviour Fractals.Output

  defstruct type: :no_output, module: __MODULE__

  def starte(_job) do
  end

  def write(_job, _pixels) do
  end

  def parse(_params) do
    %__MODULE__{}
  end

  def compute(_job) do
    %__MODULE__{}
  end
end
