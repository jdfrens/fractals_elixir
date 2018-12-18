defmodule Integration.UniprocessEngineTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Fractals.Job

  def assert_same_images(file1, file2) do
    file_contents1 = File.read!(file1)
    file_contents2 = File.read!(file2)

    assert file_contents1 == file_contents2,
           "#{inspect(file1)} and #{inspect(file2)} do not match"
  end

  test "small, red Mandelbrot" do
    job =
      Job.process(
        output: [
          type: "ppm",
          directory: "test/images",
          filename: "uniprocess-output.ppm"
        ],
        engine: [type: "uniprocess"],
        params_filename: "test/inputs/small-red-mandelbrot.yml"
      )

    UniprocessEngine.generate(job)

    assert_same_images(
      "test/expected_outputs/small-red-mandelbrot.ppm",
      "test/images/uniprocess-output.ppm"
    )
  end
end
