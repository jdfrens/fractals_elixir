defmodule CLI.Args do
  @moduledoc """
  Functions to process command-line arguments.

  The `fractal` takes a list of "job groups" on the command-line.  A job consists of a comma-separated list of elements.
  An element can be
  * a plain filename as a `:params_filename` entry for a `Job`, or
  * a plain filename prefixed with `"output_filename:" to specify an output filename.
  """

  alias CLI.Args
  alias Fractals.Job

  @type t :: %__MODULE__{
          valid?: boolean(),
          argv: OptionParser.argv(),
          errors: OptionParser.errors(),
          params_list: [keyword()] | nil,
          jobs: [Job.t()] | nil
        }

  defstruct valid?: true, argv: [], errors: [], params_list: nil, jobs: nil

  @spec process(OptionParser.argv()) :: t()
  def process(raw_args) do
    raw_args
    |> OptionParser.parse(switches: [])
    |> to_struct()
    |> parse_argv()
    |> process_params_list()
  end

  @spec to_struct({OptionParser.parsed(), OptionParser.argv(), OptionParser.errors()}) :: t()
  def to_struct({_flags, argv, errors}) do
    to_struct(argv, errors)
  end

  @spec to_struct(OptionParser.argv(), OptionParser.errors()) :: t()
  def to_struct(argv, errors) do
    %Args{
      valid?: Enum.empty?(errors),
      argv: argv,
      errors: errors
    }
  end

  @spec parse_argv(t()) :: t()
  def parse_argv(%Args{valid?: true, argv: argv} = args) do
    params_list =
      argv
      |> Enum.map(&String.split(&1, ","))
      |> Enum.map(&parse_group/1)

    Map.put(args, :params_list, params_list)
  end

  def parse_argv(args), do: args

  @spec parse_group([String.t()]) :: keyword()
  def parse_group(group) do
    Enum.map(group, &parse_group_element/1)
  end

  @spec parse_group_element(String.t()) :: {atom(), any()}
  def parse_group_element(group_element) do
    if String.starts_with?(group_element, "output_filename:") do
      {:output_filename, String.replace_leading(group_element, "output_filename:", "")}
    else
      {:params_filename, group_element}
    end
  end

  @spec process_params_list(t()) :: t()
  def process_params_list(%Args{params_list: params_list} = args) do
    jobs =
      params_list
      |> Enum.map(&Job.process(&1))

    Map.put(args, :jobs, jobs)
  end
end
