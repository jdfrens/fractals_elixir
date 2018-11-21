defmodule StageEngine.ParamsTest do
  @moduledoc false

  use ExUnit.Case, async: true

  describe "Fractals.Params.process/1" do
    test "recognizes the stage engine" do
      params = Fractals.Params.process(size: "10x2", engine: [type: "stage", chunk_size: "5"])
      assert %StageEngine.Params{type: :stage, chunk_size: 5} = params.engine
    end

    test "has a default chunk size of 1000" do
      engine = Fractals.Params.process(size: "10x2", engine: [type: "stage"]).engine
      assert engine.chunk_size == 1000
    end

    test "always computed, rounds up" do
      engine =
        Fractals.Params.process(
          size: "10x2",
          engine: [type: "stage", chunk_size: "3", chunk_count: 99_999]
        ).engine

      assert engine.chunk_count == 7
    end
  end
end
