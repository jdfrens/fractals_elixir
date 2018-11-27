defmodule StageEngine.Parser do
  @moduledoc """
  Parser for `StageEngine`.

  The stages work on chunked data parameterized by `:chunk_size` and `:chunk_count`.  `:chunk_count` is always computed.
  `chunk_size` is 1000 by default.
  """

  alias Fractals.{Chunk, Image}

  def parse_engine(params) do
    initial_engine = %StageEngine{}

    Enum.reduce(params, initial_engine, fn {attribute, value}, job ->
      %{job | attribute => parse_value(attribute, value)}
    end)
  end

  def compute_parsed(
        %Fractals.Job{
          engine: %StageEngine{chunk_size: chunk_size} = engine,
          image: %Image{
            size: %Fractals.Size{width: width, height: height}
          }
        } = job
      ) do
    %{
      job
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
