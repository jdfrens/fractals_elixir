defmodule PPMOutputTest do
  @moduledoc false

  use ExUnit.Case

  alias Fractals.{Color, Image, Job, Size}

  @filename "test/images/ppm_output_test_output.ppm"

  describe "write_everything/2" do
    test "opens, starts, writes, stops, and closes PPM output" do
      job = %Job{
        output: %PPMOutput{filename: @filename},
        image: %Image{size: %Size{width: 2, height: 2}}
      }

      pixels = Enum.map(~w(black white white black)a, &Color.rgb(&1))
      PPMOutput.write_everything(job, pixels)

      assert "P3\n2\n2\n255\n  0   0   0 \n255 255 255 \n255 255 255 \n  0   0   0 \n" ==
               File.read!(@filename)
    end
  end
end
