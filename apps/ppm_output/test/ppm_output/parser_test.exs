defmodule PPMOutput.ParserTest do
  @moduledoc false

  use ExUnit.Case, async: true

  describe "Fractals.Job.process/1" do
    alias Fractals.Job

    setup(context) do
      explicit_settings = Map.get(context, :explicit_settings, [])

      {:ok,
       argv: [
         output: [{:type, "ppm"} | explicit_settings]
       ]}
    end

    test "recognizes the PPM output type", %{argv: argv} do
      assert %PPMOutput{type: :ppm} = Job.process(argv).output
    end

    test "outputs to images directory by default", %{argv: argv} do
      assert %PPMOutput{directory: "images"} = Job.process(argv).output
    end

    @tag explicit_settings: [directory: "other_images"]
    test "overrides image directory", %{argv: argv} do
      assert %PPMOutput{directory: "other_images"} = Job.process(argv).output
    end

    @tag explicit_settings: [filename: "the-output.ppm"]
    test "parsed output_filename parameter", %{argv: argv} do
      assert Job.process(argv).output.filename == "images/the-output.ppm"
    end

    test "uses first params filename to name output", %{argv: argv} do
      argv =
        [
          params_filename: "test/inputs/full_params.yml",
          params_filename: "test/inputs/partial_params.yml"
        ] ++ argv

      assert %PPMOutput{filename: "images/full_params.ppm"} = Job.process(argv).output
    end
  end
end
