defmodule Fractals.ColorSchemeTest do
  use ExUnit.Case, async: true

  alias Fractals.ColorScheme
  alias Fractals.{Color, Job}

  describe "black on white" do
    test "colors outside" do
      params = %{Job.default() | color: %Color{type: :black_on_white}}
      assert ColorScheme.color_point({nil, 512}, params) == PPM.black()
    end

    test "colors inside" do
      params = %{Job.default() | color: %Color{type: :black_on_white}}
      assert ColorScheme.color_point({nil, 128}, params) == PPM.white()
    end
  end

  describe "white on black" do
    test "colors outside" do
      params = %{Job.default() | color: %Color{type: :white_on_black}}
      assert ColorScheme.color_point({nil, 512}, params) == PPM.white()
    end

    test "colors inside" do
      params = %{Job.default() | color: %Color{type: :white_on_black}}
      assert ColorScheme.color_point({nil, 128}, params) == PPM.black()
    end
  end

  describe "gray" do
    test "black inside" do
      params = %{Job.default() | color: %Color{type: :gray}}
      assert ColorScheme.color_point({nil, 512}, params) == PPM.black()
    end

    test "scales 0 to black" do
      params = %{Job.default() | color: %Color{type: :gray}}
      assert ColorScheme.color_point({nil, 0}, params) == PPM.black()
    end

    test "scales 128 to 180" do
      params = %{Job.default() | color: %Color{type: :gray}}
      assert ColorScheme.color_point({nil, 128}, params) == PPM.ppm(180, 180, 180)
    end

    test "white after maximum iterations" do
      params = %{Job.default() | color: %Color{type: :gray}}
      assert ColorScheme.color_point({nil, 255}, params) == PPM.white()
    end
  end

  describe "Warp POV" do
    test "red" do
      params = %{Job.default() | color: %Color{type: :red}}
      assert ColorScheme.color_point({nil, 128}, params) == PPM.ppm(255, 0, 0)
    end

    test "green" do
      params = %{Job.default() | color: %Color{type: :green}}
      assert ColorScheme.color_point({nil, 128}, params) == PPM.ppm(0, 255, 0)
    end

    test "blue" do
      params = %{Job.default() | color: %Color{type: :blue}}
      assert ColorScheme.color_point({nil, 128}, params) == PPM.ppm(0, 0, 255)
    end
  end
end
