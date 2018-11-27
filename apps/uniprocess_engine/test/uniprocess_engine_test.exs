defmodule UniprocessEngineTest do
  use ExUnit.Case

  describe "Fractals.Job.process/1" do
    test "recognizes the uniprocess engine" do
      argv = [
        engine: %{type: "uniprocess"}
      ]

      assert Fractals.Job.process(argv).engine == %UniprocessEngine{type: :uniprocess}
    end
  end
end
