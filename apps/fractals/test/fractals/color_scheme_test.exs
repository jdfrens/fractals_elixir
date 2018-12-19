defmodule Fractals.ColorSchemeTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Fractals.{Color, ColorScheme, Job}

  describe "black on white" do
    test "colors outside" do
      params = %{Job.default() | color_scheme: %ColorScheme{type: :black_on_white}}
      assert ColorScheme.color_point({nil, 512}, params) == Color.rgb(:black)
    end

    test "colors inside" do
      params = %{Job.default() | color_scheme: %ColorScheme{type: :black_on_white}}
      assert ColorScheme.color_point({nil, 128}, params) == Color.rgb(:white)
    end
  end

  describe "white on black" do
    test "colors outside" do
      params = %{Job.default() | color_scheme: %ColorScheme{type: :white_on_black}}
      assert ColorScheme.color_point({nil, 512}, params) == Color.rgb(:white)
    end

    test "colors inside" do
      params = %{Job.default() | color_scheme: %ColorScheme{type: :white_on_black}}
      assert ColorScheme.color_point({nil, 128}, params) == Fractals.Color.rgb(:black)
    end
  end

  describe "gray" do
    test "black inside" do
      params = %{Job.default() | color_scheme: %ColorScheme{type: :gray}}
      assert ColorScheme.color_point({nil, 512}, params) == Color.rgb(:black)
    end

    test "scales 0 to black" do
      params = %{Job.default() | color_scheme: %ColorScheme{type: :gray}}
      assert ColorScheme.color_point({nil, 0}, params) == Color.rgb(:black)
    end

    test "half iterations is a bit more than half intensity" do
      expected_intensity = 0.7071067811865476
      params = %{Job.default() | color_scheme: %ColorScheme{type: :gray}}

      assert ColorScheme.color_point({nil, 128}, params) ==
               Color.rgb(expected_intensity, expected_intensity, expected_intensity)
    end

    test "(close to) white after maximum iterations" do
      expected_intensity = 0.998044963916957
      params = %{Job.default() | color_scheme: %ColorScheme{type: :gray}}

      assert ColorScheme.color_point({nil, 255}, params) ==
               Color.rgb(expected_intensity, expected_intensity, expected_intensity)
    end
  end

  describe "Warp POV" do
    test "red" do
      params = %{Job.default() | color_scheme: %ColorScheme{type: :red}}
      assert ColorScheme.color_point({nil, 128}, params) == Color.rgb(1.0, 0.0, 0.0)
    end

    test "green" do
      params = %{Job.default() | color_scheme: %ColorScheme{type: :green}}
      assert ColorScheme.color_point({nil, 128}, params) == Color.rgb(0.0, 1.0, 0.0)
    end

    test "blue" do
      params = %{Job.default() | color_scheme: %ColorScheme{type: :blue}}
      assert ColorScheme.color_point({nil, 128}, params) == Color.rgb(0.0, 0.0, 1.0)
    end
  end
end
