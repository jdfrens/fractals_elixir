defmodule Fractals.Application do
  @moduledoc false

  use Application

  @initial_parsers %{
    {:color, :_} => Fractals.Color,
    {:fractal, "burning_ship"} => Fractals.EscapeTime.BurningShip,
    {:fractal, "julia"} => Fractals.EscapeTime.Julia,
    {:fractal, "mandelbrot"} => Fractals.EscapeTime.Mandelbrot,
    {:fractal, "newton"} => Fractals.UnimplementedFractal,
    {:fractal, "nova"} => Fractals.UnimplementedFractal,
    {:output, :_} => Fractals.Output
  }

  def start(_type, _args) do
    children = [
      # registry
      {Fractals.ParserRegistry, @initial_parsers},
      # color
      Fractals.Colorizer.Random,
      # image output
      {DynamicSupervisor, strategy: :one_for_one, name: Fractals.OutputWorkerSupervisor},
      {Registry, keys: :unique, name: Fractals.OutputWorkerRegistry},
      # reporters
      Fractals.Reporters.Supervisor,
      Fractals.Reporters.Broadcaster
    ]

    opts = [strategy: :one_for_one, name: CLI.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
