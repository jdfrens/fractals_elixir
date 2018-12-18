defmodule Fractals.ColorScheme.RandomTest do
  use ExUnit.Case

  alias Fractals.ColorScheme.Random
  alias Fractals.{Color, Job}

  setup do
    Random.start_link(:ok)
    :ok
  end

  describe ".at" do
    test "returning a color" do
      assert {:rgb, red, green, blue} = Random.at(Random, 127, Job.default())
      assert 0.0 <= red and red <= 1.0
      assert 0.0 <= green and green <= 1.0
      assert 0.0 <= blue and blue <= 1.0
    end

    test "returns the same color for the same iterations" do
      color = Random.at(Random, 52, Job.default())
      assert Random.at(Random, 52, Job.default()) == color
      assert Random.at(Random, 52, Job.default()) == color
      assert Random.at(Random, 52, Job.default()) == color
    end

    test "returning black for max iterations" do
      assert Random.at(Random, Job.default().fractal.max_iterations, Job.default()) ==
               Color.rgb(:black)
    end
  end
end
