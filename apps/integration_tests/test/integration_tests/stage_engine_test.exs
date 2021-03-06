defmodule Integration.StageEngineTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Fractals.Job
  alias Fractals.Reporters.{Broadcaster, Countdown}

  @spec assert_same_images(String.t(), String.t()) :: any()
  def assert_same_images(file1, file2) do
    file_contents1 = File.read!(file1)
    file_contents2 = File.read!(file2)

    assert file_contents1 == file_contents2,
           "#{inspect(file1)} and #{inspect(file2)} do not match"
  end

  test "small, red Mandelbrot PPM" do
    job =
      Job.process(
        output: [
          type: "ppm",
          directory: "test/images",
          filename: "stage-engine-output.ppm"
        ],
        engine: [type: "stage"],
        params_filename: "test/inputs/small-red-mandelbrot.yml"
      )

    Broadcaster.add_reporter(Countdown, %{jobs: [job], for: self()})

    StageEngine.generate(job)

    assert_receive {:jobs_countdown_done, _reason}, 20_000

    assert_same_images(
      "test/expected_outputs/small-red-mandelbrot.ppm",
      "test/images/stage-engine-output.ppm"
    )
  end

  test "small, red Mandelbrot PNG" do
    job =
      Job.process(
        output: [
          type: "png",
          directory: "test/images",
          filename: "stage-engine-output.png"
        ],
        engine: [type: "stage"],
        params_filename: "test/inputs/small-red-mandelbrot.yml"
      )

    Broadcaster.add_reporter(Countdown, %{jobs: [job], for: self()})

    StageEngine.generate(job)

    assert_receive {:jobs_countdown_done, _reason}, 20_000

    assert_same_images(
      "test/expected_outputs/small-red-mandelbrot.png",
      "test/images/stage-engine-output.png"
    )
  end
end
