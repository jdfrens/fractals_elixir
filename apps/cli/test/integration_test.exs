defmodule CLI.IntegrationTest do
  use ExUnit.Case

  # credo:disable-for-this-file Credo.Check.Design.AliasUsage

  @mandelbrot_input_filename "test/inputs/integration_mandelbrot.yml"
  @mandelbrot_output_filename "test/images/integration_mandelbrot.ppm"

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
    if File.exists?(@mandelbrot_output_filename) do
      File.rm!(@mandelbrot_output_filename)
    end

    :ok
  end

  test "generates a pretty picture" do
    alias Fractals.Reporters.{Broadcaster, Countdown}

    job =
      Fractals.Job.process(
        output: [directory: "test/images"],
        engine: [type: "stage"],
        params_filename: @mandelbrot_input_filename
      )

    ExUnit.CaptureIO.capture_io(fn ->
      Broadcaster.add_reporter(Countdown, %{jobs: [job], for: self()})
      Fractals.fractalize(job)
      CLI.wait(nil)
    end)

    output = File.read!(@mandelbrot_output_filename)
    assert output == @expected_output
  end
end
