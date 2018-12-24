defmodule PNGOutputTest do
  @moduledoc false

  use ExUnit.Case

  alias Fractals.{Color, Image, Job, Size}

  @filename "test/images/png_output_test_output.png"

  describe "write_everything/2" do
    test "opens, starts, writes, stops, and closes PPM output" do
      job = %Job{
        output: %PNGOutput{filename: @filename},
        image: %Image{size: %Size{width: 2, height: 3}}
      }

      pixels = Enum.map(~w(black white  white black  black white)a, &Color.rgb(&1))
      PNGOutput.write_everything(job, pixels)

      assert <<137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 2, 0, 0, 0,
               3, 8, 2, 0, 0, 0, 54, 136, 73, 214, 0, 0, 0, 20, 73, 68, 65, 84, 120, 156, 99, 96,
               96, 96, 248, 255, 255, 63, 24, 67, 0, 144, 5, 0, 89, 187, 8, 248, 31, 159, 129,
               199, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130>> == File.read!(@filename)
    end
  end
end
