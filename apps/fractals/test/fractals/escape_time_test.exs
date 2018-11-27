defmodule Fractals.EscapeTimeTest do
  use ExUnit.Case, async: true

  alias Fractals.Fractal

  defmodule EscapingIteration do
    @moduledoc "A fake escape-time fractal."

    use Fractals.EscapeTime

    @impl Fractals.Fractal
    def parse(_params) do
      %Fractals.Fractal{}
    end

    @impl Fractals.EscapeTime
    def iterate(grid_point, fractal) do
      Stream.iterate(grid_point, &Complex.add(&1, fractal.algorithm_params.c))
    end
  end

  defmodule InsideIteration do
    @moduledoc "A fake escape-time fractal."

    use Fractals.EscapeTime

    @impl Fractals.Fractal
    def parse(_params) do
      %Fractals.Fractal{}
    end

    @impl Fractals.EscapeTime
    def iterate(grid_point, _fractal) do
      Stream.iterate(grid_point, fn z -> z end)
    end
  end

  test "stops when iteration gets too large" do
    grid_point = Complex.new(1.0)

    fractal = %Fractal{
      module: EscapingIteration,
      algorithm_params: %{
        c: Complex.new(1.0)
      }
    }

    assert EscapingIteration.generate([grid_point], fractal) == [{Complex.new(2.0), 1}]
  end

  test "uses grid point and params" do
    grid_point = Complex.new(0.0)

    fractal = %Fractal{
      module: EscapingIteration,
      algorithm_params: %{
        c: Complex.new(0.5)
      }
    }

    assert EscapingIteration.generate([grid_point], fractal) == [{Complex.new(2.0), 4}]
  end

  test "stops when max iterations reached" do
    grid_point = Complex.new(1.0)

    fractal = %Fractal{
      module: EscapingIteration,
      algorithm_params: %{
        c: Complex.new(0.0)
      }
    }

    assert InsideIteration.generate([grid_point], fractal) == [{Complex.new(1.0), 256}]
  end

  test "iterates over all grid points" do
    grid_points = [Complex.new(0.5), Complex.new(-1.0)]

    fractal = %Fractal{
      module: EscapingIteration,
      algorithm_params: %{
        c: Complex.new(1.0)
      }
    }

    assert EscapingIteration.generate(grid_points, fractal) == [
             {Complex.new(2.5), 2},
             {Complex.new(2.0), 3}
           ]
  end
end
