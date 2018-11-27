defmodule Fractals.Application do
  @moduledoc false

  use Application

  @escape_time_fractals %{
    "burning_ship" => Fractals.EscapeTime.BurningShip,
    "julia" => Fractals.EscapeTime.Julia,
    "mandelbrot" => Fractals.EscapeTime.Mandelbrot
  }
  @unimplemented_fractals %{
    "newton" => Fractals.UnimplementedFractal,
    "nova" => Fractals.UnimplementedFractal
  }
  @fractals Map.merge(@escape_time_fractals, @unimplemented_fractals)

  def start(_type, _args) do
    children = [
      # registries
      Fractals.EngineRegistry,
      {Fractals.FractalRegistry, @fractals},
      # color
      Fractals.Colorizer.Random,
      # image output
      {DynamicSupervisor, strategy: :one_for_one, name: Fractals.OutputWorkerSupervisor},
      Fractals.ConversionWorker,
      {Registry, keys: :unique, name: Fractals.OutputWorkerRegistry},
      # reporters
      Fractals.Reporters.Supervisor,
      Fractals.Reporters.Broadcaster
    ]

    opts = [strategy: :one_for_one, name: CLI.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
