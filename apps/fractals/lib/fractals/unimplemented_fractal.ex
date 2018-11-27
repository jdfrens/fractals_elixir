defmodule Fractals.UnimplementedFractal do
  @moduledoc """
  A placeholder for an unimplemented fractal.

  Not all fractals exercised by the data files are implemented.  This is a placeholder so that parsing the job does not
  blow up.  The CLI filters these fractals out with a "I'm skipping this" message.
  """

  @behaviour Fractals.Fractal

  @impl Fractals.Fractal
  def parse(_params) do
    %Fractals.Fractal{
      type: :unimplemented,
      module: __MODULE__
    }
  end

  @impl Fractals.Fractal
  def generate(_, _) do
    []
  end
end
