defmodule StageEngine do
  @moduledoc """
  Documentation for StageEngine.
  """

  use Fractals.Engine

  alias StageEngine.GridWorker

  @type t :: %__MODULE__{
          type: :stage,
          module: StageEngine,
          chunk_size: integer(),
          chunk_count: integer() | nil
        }

  defstruct type: :stage,
            module: StageEngine,
            chunk_size: 1000,
            chunk_count: nil

  @impl Fractals.Engine
  defdelegate parse_engine(params), to: StageEngine.Parser

  @impl Fractals.Engine
  defdelegate compute_parsed(params), to: StageEngine.Parser

  @impl Fractals.Engine
  def generate(job) do
    GridWorker.work(StageEngine.GridWorker, job)
  end
end
