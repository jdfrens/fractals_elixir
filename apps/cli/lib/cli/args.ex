defmodule CLI.Args do
  alias Fractals.Params

  @type filename_group :: [String.t()]
  @type t :: %__MODULE__{
          valid?: boolean(),
          argv: OptionParser.argv(),
          errors: OptionParser.errors(),
          raw_params_list: [keyword()] | nil,
          params_list: [Params.t()] | nil
        }

  defstruct valid?: true, argv: [], errors: [], raw_params_list: nil, params_list: nil

  alias CLI.Args

  @spec process(OptionParser.argv()) :: t()
  def process(raw_args) do
    raw_args
    |> OptionParser.parse(switches: [])
    |> to_struct()
    |> parse_filename_groups()
    |> process_raw_params()
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

  @spec parse_filename_groups(t()) :: t()
  def parse_filename_groups(%Args{valid?: true, argv: argv} = args) do
    raw_params_list =
      argv
      |> Enum.map(&String.split(&1, ","))
      |> Enum.map(&parse_filename_group/1)

    Map.put(args, :raw_params_list, raw_params_list)
  end

  def parse_params_groups(args), do: args

  @spec parse_filename_group(filename_group()) :: keyword()
  def parse_filename_group(group) do
    Enum.map(group, &parse_group_element/1)
  end

  @spec parse_group_element(String.t()) :: {atom(), any()}
  def parse_group_element(group_element) do
    cond do
      # TODO: untested
      String.starts_with?(group_element, "output_file:") ->
        {:output_filename, String.replace_leading(group_element, "output_file:", "")}

      true ->
        {:params_filename, group_element}
    end
  end

  @spec process_raw_params(t()) :: t()
  def process_raw_params(%Args{raw_params_list: raw_params_list} = args) do
    params_list =
      raw_params_list
      |> Enum.map(&Params.process(&1))

    Map.put(args, :params_list, params_list)
  end
end
