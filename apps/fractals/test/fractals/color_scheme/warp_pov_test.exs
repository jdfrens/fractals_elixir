defmodule Fractals.ColorScheme.WarpPovTest do
  use ExUnit.Case, async: true

  alias Fractals.ColorScheme.WarpPov
  alias Fractals.{Color, Job}

  @iteration_127 0.984375

  setup do
    [job: Job.default()]
  end

  describe ".red" do
    test "treats the primary hue as red", %{job: job} do
      assert WarpPov.red(127, job) == Color.rgb(@iteration_127, 0.0, 0.0)
    end
  end

  describe ".green" do
    test "treats the primary hue as green", %{job: job} do
      assert WarpPov.green(127, job) == Color.rgb(0.0, @iteration_127, 0.0)
    end
  end

  describe ".blue" do
    test "treats the primary hue as blue", %{job: job} do
      assert WarpPov.blue(127, job) == Color.rgb(0.0, 0.0, @iteration_127)
    end
  end

  describe ".intensities" do
    test "is black inside", %{job: job} do
      assert {0.0, 0.0} = WarpPov.intensities(256, job)
    end

    test "is all 0.0 for 0 iterations", %{job: job} do
      assert {0.0, 0.0} = WarpPov.intensities(0, job)
    end

    test "is all 0.0 for 1 iteration", %{job: job} do
      assert {0.0, 0.0} = WarpPov.intensities(1, job)
    end

    test "is small primary color for 2 iteration", %{job: job} do
      assert {0.0078125, _} = WarpPov.intensities(2, job)
    end

    test "is intense primary for 127 (half minus one) iterations", %{job: job} do
      assert {@iteration_127, _} = WarpPov.intensities(127, job)
    end

    test "is secondary 0.0 for 128 (half max) iterations", %{job: job} do
      assert {_, 0.0} = WarpPov.intensities(128, job)
    end

    test "is intense secondary for 255 iterations", %{job: job} do
      assert {_, 0.9921875} = WarpPov.intensities(255, job)
    end
  end

  describe ".scale" do
    test "scales 1 iteration to 0", %{job: job} do
      assert WarpPov.scale(1, job) == 0.0
    end

    test "scales 127 iterations to close-to-max", %{job: job} do
      assert WarpPov.scale(127, job) == @iteration_127
    end

    test "scales half of max iterations to (close to) max intensity", %{job: job} do
      assert WarpPov.scale(128, job) == 0.9921875
    end
  end
end
