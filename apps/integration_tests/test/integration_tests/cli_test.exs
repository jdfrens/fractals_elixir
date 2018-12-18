defmodule Integration.CLITest do
  use ExUnit.Case

  # credo:disable-for-this-file Credo.Check.Design.AliasUsage

  @input_filename "test/inputs/mandelbrot.yml"
  @output_filename "test/images/mandelbrot.ppm"

  @expected_output [
                     "P3",
                     "2",
                     "2",
                     "255",
                     "255 255 255 ",
                     "255 255 255 ",
                     "  0   0   0 ",
                     "255 255 255 ",
                     ""
                   ]
                   |> Enum.join("\n")

  setup do
    if File.exists?(@output_filename) do
      File.rm!(@output_filename)
    end

    :ok
  end

  test "generates a pretty picture" do
    alias Fractals.Reporters.{Broadcaster, Countdown}

    job =
      Fractals.Job.process(
        output: [type: "ppm", directory: "test/images"],
        engine: [type: "stage"],
        params_filename: @input_filename
      )

    ExUnit.CaptureIO.capture_io(fn ->
      Broadcaster.add_reporter(Countdown, %{jobs: [job], for: self()})
      Fractals.fractalize(job)
      CLI.wait(nil)
    end)

    output = File.read!(@output_filename)
    assert output == @expected_output
  end
end
