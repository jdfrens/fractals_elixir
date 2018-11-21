defmodule StageEngine do
  @moduledoc """
  Documentation for StageEngine.
  """

  @behaviour Fractals.Behaviours.Engine

  alias StageEngine.GridWorker

  @impl Fractals.Behaviours.Engine
  def generate(params) do
    GridWorker.work(StageEngine.GridWorker, params)
  end
end
