defmodule Fractals.Job do
  @moduledoc """
  Structure for a job to construct a fractal.
  """

  import Complex, only: :macros

  alias Fractals.{ColorRegistry, EngineRegistry, FractalRegistry}
  alias Fractals.Engines.DoNothingEngine
  alias Fractals.{Color, Fractal, Image, Job, Size}

  @type fractal_id :: String.t()
  @type t :: %__MODULE__{
          id: fractal_id() | nil,
          seed: integer() | nil,
          image: Image.t() | nil,
          engine: map() | nil,
          fractal: Fractals.Fractal.t() | nil,
          color: Color.t() | nil,
          params_filenames: [String.t()] | nil,
          output_directory: String.t() | nil,
          output_filename: String.t() | nil,
          ppm_filename: String.t() | nil,
          output_pid: pid() | nil
        }

  defstruct [
    # operational
    :id,
    :seed,
    :engine,
    :fractal,
    :image,
    :color,
    # input
    :params_filenames,
    # output
    :output_directory,
    :output_filename,
    :ppm_filename,
    :output_pid
  ]

  @spec default :: Job.t()
  def default do
    %Job{
      seed: 666,
      engine: %DoNothingEngine{},
      fractal: %Fractal{
        type: :mandelbrot,
        module: Fractals.EscapeTime.Mandelbrot
      },
      image: %Image{
        lower_right: Complex.new(6.0, 5.0),
        max_intensity: 255,
        size: %Size{width: 512, height: 384},
        upper_left: Complex.new(5.0, 6.0)
      },
      color: %Color{
        type: :black_on_white,
        max_intensity: 255
      },
      params_filenames: [],
      output_directory: "images"
    }
  end

  @computed_attributes [
    :id,
    # compute params_filenames before output_filename
    :params_filenames,
    :output_filename,
    :ppm_filename,
    :output_pid
  ]
  # IDEA: this could be a param
  @output_extension ".png"

  # IDEA: don't let user set some values (like output_pid)
  # IDEA: add `postcheck` after `compute` to check necessary values

  @spec process(map | keyword, Job.t()) :: Job.t()
  def process(params, base_job \\ default()) do
    params
    |> parse(base_job)
    |> compute()
  end

  @spec parse(map | keyword, Job.t()) :: Job.t()
  def parse(params, base_job \\ default()) do
    params
    |> Enum.reduce(base_job, &parse_attribute/2)
  end

  @spec close(Job.t()) :: Job.t()
  def close(job) do
    :ok = File.close(job.output_pid)
    job
  end

  # *******
  # Parsing
  # *******

  @spec parse_attribute({atom, any}, Job.t()) :: Job.t()
  defp parse_attribute({:params_filename, filename}, job) do
    with {:ok, raw_yaml} <- YamlElixir.read_from_file(filename),
         yaml <- symbolize(raw_yaml),
         params_filenames = [filename | job.params_filenames],
         %Job{} = parsed <- parse(yaml, %{job | params_filenames: params_filenames}) do
      parsed
    else
      {:error, reason} ->
        {:error, "could not parse #{filename}: #{reason}"}
    end
  end

  defp parse_attribute({attribute, value}, job) do
    %{job | attribute => parse_value(attribute, value)}
  end

  @spec parse_value(atom, String.t()) :: %{type: atom(), module: module()}
  defp parse_value(:color, value) do
    color_params = symbolize(value)

    color_params
    |> Map.get(:type)
    |> String.downcase()
    |> ColorRegistry.get()
    |> apply(:parse, [color_params])
  end

  defp parse_value(:engine, value) do
    engine_params = symbolize(value)

    engine_params
    |> Map.get(:type)
    |> EngineRegistry.get()
    |> apply(:parse_engine, [engine_params])
  end

  defp parse_value(:fractal, value) do
    fractal_params = symbolize(value)

    fractal_params
    |> Map.get(:type)
    |> String.downcase()
    |> FractalRegistry.get()
    |> apply(:parse, [fractal_params])
  end

  defp parse_value(:image, value) do
    Image.parse(symbolize(value))
  end

  defp parse_value(_attribute, value), do: value

  # **********
  # Compute
  # **********

  @spec compute(Job.t()) :: Job.t()
  defp compute(job) do
    job
    |> compute_attributes()
    |> compute_engine()
  end

  @spec compute_engine(Job.t()) :: Job.t()
  defp compute_engine(%Job{engine: nil} = job) do
    job
  end

  defp compute_engine(%Job{engine: %{module: module}} = job) do
    apply(module, :compute_parsed, [job])
  end

  @spec compute_attributes(Job.t()) :: Job.t()
  defp compute_attributes(job) do
    Enum.reduce(@computed_attributes, job, &compute_attribute/2)
  end

  @spec compute_attribute(atom, Job.t()) :: Job.t()
  defp compute_attribute(attribute, job) do
    %{job | attribute => compute_value(attribute, job)}
  end

  @spec compute_value(atom, Job.t()) :: any
  defp compute_value(:id, _job) do
    UUID.uuid1()
  end

  defp compute_value(:params_filenames, %Job{params_filenames: params_filenames}) do
    Enum.reverse(params_filenames)
  end

  defp compute_value(:output_filename, job) do
    if job.output_filename == nil do
      case job.params_filenames do
        [] ->
          nil

        [filename] ->
          output_basepath(filename, job) <> @output_extension

        _ ->
          nil
      end
    else
      Path.join(job.output_directory, job.output_filename)
    end
  end

  defp compute_value(:ppm_filename, job) do
    case job.output_filename do
      nil ->
        nil

      filename ->
        output_basepath(filename, job) <> ".ppm"
    end
  end

  defp compute_value(:output_pid, job) do
    case job.ppm_filename do
      nil ->
        nil

      filename ->
        File.open!(filename, [:write])
    end
  end

  @spec output_basepath(String.t(), Job.t()) :: String.t()
  defp output_basepath(filename, job) do
    Path.join(job.output_directory, basename(filename))
  end

  @spec basename(String.t()) :: String.t()
  defp basename(filename) do
    filename
    |> Path.basename(".yml")
    |> Path.basename(".png")
    |> Path.basename(".ppm")
  end

  # *******
  # Helpers
  # *******

  @spec symbolize(Enumerable.t()) :: map
  defp symbolize(job) do
    for {key, val} <- job, into: %{}, do: {to_atom(key), val}
  end

  @spec to_atom(atom | String.t()) :: atom
  defp to_atom(key) when is_atom(key), do: key
  defp to_atom(key), do: String.to_atom(Macro.underscore(key))
end
