defmodule Fractals.ColorScheme.RandomTest do
  use ExUnit.Case

  alias Fractals.ColorScheme.Random
  alias Fractals.{Image, Job}

  setup do
    Random.start_link(:ok)
    :ok
  end

  describe ".at" do
    test "returning a color" do
      assert Regex.match?(
               ~r/\s*\d{1,3}\s+\d{1,3}\s+\d{1,3}/,
               Random.at(Random, 127, Job.default())
             )
    end

    test "returns the same color for the same iterations" do
      color = Random.at(Random, 52, Job.default())
      assert Random.at(Random, 52, Job.default()) == color
      assert Random.at(Random, 52, Job.default()) == color
      assert Random.at(Random, 52, Job.default()) == color
    end

    test "returning black for max iterations" do
      assert Random.at(Random, Job.default().fractal.max_iterations, Job.default()) == PPM.black()
    end
  end

  describe ".pick_colors" do
    test "scales based on max_intensity" do
      colors = [[0.2, 0.5, 0.8]]
      image = %Image{max_intensity: 256}
      job = %{Job.default() | image: image}
      assert Random.pick_color(colors, 0, job) == [51, 128, 205]
    end
  end
end
