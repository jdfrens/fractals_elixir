defmodule Fractals.ColorScheme.WarpPovTest do
  use ExUnit.Case, async: true

  alias Fractals.ColorScheme.WarpPov
  alias Fractals.Job

  setup do
    [job: Job.default()]
  end

  describe ".red" do
    test "treats the primary hue as red", %{job: job} do
      assert WarpPov.red(127, job) == PPM.ppm(251, 0, 0)
    end
  end

  describe ".green" do
    test "treats the primary hue as green", %{job: job} do
      assert WarpPov.green(127, job) == PPM.ppm(0, 251, 0)
    end
  end

  describe ".blue" do
    test "treats the primary hue as blue", %{job: job} do
      assert WarpPov.blue(127, job) == PPM.ppm(0, 0, 251)
    end
  end

  describe ".intensities" do
    test "is black inside", %{job: job} do
      assert WarpPov.intensities(256, job) == {0, 0}
    end

    test "is all 0 for 0 iterations", %{job: job} do
      assert WarpPov.intensities(0, job) == {0, 0}
    end

    test "is all 0 for 1 iteration", %{job: job} do
      assert WarpPov.intensities(1, job) == {0, 0}
    end

    test "is primary 2 for 2 iteration", %{job: job} do
      assert WarpPov.intensities(2, job) == {2, 0}
    end

    test "is primary 251 for 127 (half minus one) iterations", %{job: job} do
      assert WarpPov.intensities(127, job) == {251, 0}
    end

    test "is secondary 0 for 128 (half max) iterations", %{job: job} do
      assert WarpPov.intensities(128, job) == {255, 0}
    end

    test "is 253 secondary for 255 iterations", %{job: job} do
      assert WarpPov.intensities(255, job) == {255, 253}
    end
  end

  describe ".scale" do
    test "scales 1 iteration to 0", %{job: job} do
      assert WarpPov.scale(1, job) == 0
    end

    test "scales 64 iterations to 251", %{job: job} do
      assert WarpPov.scale(127, job) == 251
    end

    test "scales half of max iterations to max intensity", %{job: job} do
      assert WarpPov.scale(128, job) == 253
    end
  end
end
