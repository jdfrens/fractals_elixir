defmodule StageEngine.Params do
  @moduledoc """
  Params for the stage engine.

  The stages work on chunked data parameterized by `:chunk_size` and `:chunk_count`.  `:chunk_count` is always computed.
  `chunk_size` is 1000 by default.
  """

  use Fractals.Behaviours.EngineParamsParser

  alias Fractals.Chunk

  @type t :: %__MODULE__{
          type: :stage,
          module: StageEngine,
          params_parser: StageEngine.Params,
          chunk_size: integer(),
          chunk_count: integer() | nil
        }

  defstruct type: :stage,
            module: StageEngine,
            params_parser: StageEngine.Params,
            chunk_size: 1000,
            chunk_count: nil

  @impl Fractals.Behaviours.EngineParamsParser
  def parse(raw_params) do
    initial_params = %__MODULE__{}

    Enum.reduce(raw_params, initial_params, fn {attribute, value}, params ->
      %{params | attribute => parse_value(attribute, value)}
    end)
  end

  @impl Fractals.Behaviours.EngineParamsParser
  def compute(
        %Fractals.Params{
          engine: %StageEngine.Params{chunk_size: chunk_size} = engine,
          size: %Fractals.Size{width: width, height: height}
        } = fractals_params
      ) do
    %{
      fractals_params
      | engine: %{engine | chunk_count: Chunk.chunk_count(width, height, chunk_size)}
    }
  end

  defp parse_value(:chunk_size, chunk_size) when is_binary(chunk_size) do
    String.to_integer(chunk_size)
  end

  defp parse_value(:chunk_size, chunk_size) do
    chunk_size
  end

  defp parse_value(:type, "stage") do
    :stage
  end

  defp parse_value(_, _) do
    :invalid_attribute
  end
end
