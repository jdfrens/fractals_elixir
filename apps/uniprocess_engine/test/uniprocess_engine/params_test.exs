defmodule UniprocessEngine.ParamsTest do
  @moduledoc false

  use ExUnit.Case, async: true

  describe "Fractals.Params.process/1" do
    test "recognizes the uniprocess engine" do
      argv = [
        engine: %{type: "uniprocess"}
      ]

      assert Fractals.Params.process(argv).engine == %UniprocessEngine.Params{type: :uniprocess}
    end
  end
end
