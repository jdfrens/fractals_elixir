defmodule Fractals.Job do
  @moduledoc """
  Structure for a job to construct a fractal.
  """

  import Complex, only: :macros

  alias Fractals.ParserRegistry
  alias Fractals.{ColorScheme, Image, Job, Size}

  @type fractal_id :: String.t()
  @type t :: %__MODULE__{
          id: fractal_id() | nil,
          seed: integer() | nil,
          image: Image.t() | nil,
          engine: map() | nil,
          fractal: Fractals.Fractal.t() | nil,
          color_scheme: Fractals.ColorScheme.t() | nil,
          params_filenames: [String.t()] | nil,
          output: Fractals.Output.t() | nil
        }

  defstruct [
    :id,
    :seed,
    :engine,
    :fractal,
    :image,
    :color_scheme,
    :output,
    :params_filenames
  ]

  @spec default :: Job.t()
  def default do
    %Job{
      seed: 666,
      engine: %Fractals.Engines.DoNothingEngine{},
      fractal: %Fractals.Fractal{
        type: :mandelbrot,
        module: Fractals.EscapeTime.Mandelbrot
      },
      image: %Image{
        lower_right: Complex.new(6.0, 5.0),
        size: %Size{width: 512, height: 384},
        upper_left: Complex.new(5.0, 6.0)
      },
      color_scheme: %ColorScheme{
        type: :black_on_white
      },
      params_filenames: [],
      output: %Fractals.Outputs.NoOutput{}
    }
  end

  @computed_attributes [
    :id,
    :fractal,
    :engine,
    :params_filenames,
    :output
  ]

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
    :ok = File.close(job.output.pid)
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
  defp parse_value(:color_scheme, value) do
    color_params = symbolize(value)

    type =
      color_params
      |> Map.get(:type)
      |> String.downcase()
      |> String.to_atom()

    :color_scheme
    |> ParserRegistry.get(type)
    |> apply(:parse, [color_params])
  end

  defp parse_value(:engine, value) do
    engine_params = symbolize(value)

    type =
      engine_params
      |> Map.get(:type)
      |> String.to_atom()

    :engine
    |> ParserRegistry.get(type)
    |> apply(:parse_engine, [engine_params])
  end

  defp parse_value(:fractal, value) do
    fractal_params = symbolize(value)

    type =
      fractal_params
      |> Map.get(:type)
      |> Inflex.underscore()
      |> String.to_atom()

    :fractal
    |> ParserRegistry.get(type)
    |> apply(:parse, [fractal_params])
  end

  defp parse_value(:output, value) do
    output_params = symbolize(value)

    type =
      output_params
      |> Map.get(:type)
      |> String.to_atom()

    :output
    |> ParserRegistry.get(type)
    |> apply(:parse, [output_params])
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
    compute_attributes(job)
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
  defp compute_value(:engine, %Job{engine: nil}) do
    nil
  end

  defp compute_value(:engine, %Job{engine: %{module: module}} = job) do
    apply(module, :compute_parsed, [job])
  end

  defp compute_value(:fractal, job) do
    job.fractal
  end

  defp compute_value(:id, _job) do
    UUID.uuid1()
  end

  defp compute_value(:output, %Job{output: %{type: type}} = job) do
    :output
    |> ParserRegistry.get(type)
    |> apply(:compute, [job])
  end

  defp compute_value(:params_filenames, %Job{params_filenames: params_filenames}) do
    Enum.reverse(params_filenames)
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
