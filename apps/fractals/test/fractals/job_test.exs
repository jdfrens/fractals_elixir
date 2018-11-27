defmodule Fractals.JobTest do
  use ExUnit.Case, async: true

  alias Fractals.{Color, Fractal, Job, Size}

  describe ".process a full set of params" do
    setup do
      [argv: [params_filename: "test/inputs/full_params.yml"]]
    end

    test "parsing the fractal type", %{argv: argv} do
      assert Job.process(argv).fractal == %Fractal{
               type: :mandelbrot,
               module: Fractals.EscapeTime.Mandelbrot
             }
    end

    test "parsing the image size", %{argv: argv} do
      assert Job.process(argv).image.size == %Size{width: 720, height: 480}
    end

    test "parsing the color scheme", %{argv: argv} do
      assert Job.process(argv).color == %Color{type: :blue}
    end

    test "parsing the random seed", %{argv: argv} do
      assert Job.process(argv).seed == 12_345
    end

    test "parsing the upper-left corner", %{argv: argv} do
      assert Job.process(argv).image.upper_left == Complex.new(0.0, 55.2)
    end

    test "parsing the lower-right corder", %{argv: argv} do
      assert Job.process(argv).image.lower_right == Complex.new(92.3, 120.3)
    end

    test "parsed output_filename parameter", %{argv: argv} do
      assert Job.process(argv).output.filename == "test/images/the-output.png"
    end

    test "precomputing the ppm_filename parameter (cannot be overridden)", %{argv: argv} do
      assert Job.process(argv).output.ppm_filename == "test/images/the-output.ppm"
    end
  end

  describe ".process and relying on defaults" do
    setup do
      [argv: []]
    end

    test "defaults to Mandelbrot", %{argv: argv} do
      assert Job.process(argv).fractal == %Fractal{
               type: :mandelbrot,
               module: Fractals.EscapeTime.Mandelbrot
             }
    end

    test "defaults the image size", %{argv: argv} do
      assert Job.process(argv).image.size == %Size{width: 512, height: 384}
    end

    test "defaults the color scheme", %{argv: argv} do
      assert Job.process(argv).color == %Color{
               type: :black_on_white
             }
    end

    test "defaults the random seed", %{argv: argv} do
      assert Job.process(argv).seed == 666
    end

    test "still parsing the upper-left corner", %{argv: argv} do
      assert Job.process(argv).image.upper_left == Complex.new(5.0, 6.0)
    end

    test "still parsing the lower-right corder", %{argv: argv} do
      assert Job.process(argv).image.lower_right == Complex.new(6.0, 5.0)
    end

    test "empty list of params filenames", %{argv: argv} do
      assert Job.process(argv).params_filenames == []
    end

    test "outputs to images directory", %{argv: argv} do
      assert Job.process(argv).output.directory == "images"
    end
  end

  describe "parsing flags and input file" do
    setup do
      argv = [
        seed: 700,
        params_filename: "test/inputs/partial_params.yml",
        fractal: [
          type: "burning_ship"
        ]
      ]

      [argv: argv]
    end

    test "recognizes the early flag", %{argv: argv} do
      assert Job.process(argv).seed == 700
    end

    test "recognizes a value from the file", %{argv: argv} do
      assert Job.process(argv).color == %Color{type: :blue}
    end

    test "recognizes a value overridden by a flag", %{argv: argv} do
      assert Job.process(argv).fractal == %Fractal{
               type: :burning_ship,
               module: Fractals.EscapeTime.BurningShip
             }
    end
  end

  describe "parsing multiple files" do
    setup do
      argv = [
        params_filename: "test/inputs/simple.yml",
        params_filename: "test/inputs/partial_params.yml"
      ]

      [argv: argv]
    end

    test "first file is used", %{argv: argv} do
      assert Job.process(argv).image.size == %Size{width: 720, height: 480}
    end

    test "second file wins", %{argv: argv} do
      assert Job.process(argv).fractal == %Fractal{
               type: :julia,
               module: Fractals.EscapeTime.Julia,
               algorithm_params: %{
                 c: Complex.new(1.0)
               }
             }
    end

    test "uses first params filename to name output", %{argv: argv} do
      assert Job.process(argv).output.filename == "test/images/simple.png"
    end
  end
end
