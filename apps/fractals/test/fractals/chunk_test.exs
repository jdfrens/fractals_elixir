defmodule Fractals.ChunkTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Fractals.Chunk

  describe "chunk_count/3" do
    test "divides evenly" do
      width = 10
      height = 2
      chunk_size = 5
      assert Chunk.chunk_count(width, height, chunk_size) == 4
    end

    test "adds one for a remainder" do
      width = 10
      height = 2
      chunk_size = 3
      assert Chunk.chunk_count(width, height, chunk_size) == 7
    end
  end
end
