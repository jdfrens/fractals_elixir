defmodule PNGOutput.Parser do
  @moduledoc """
  Parser for `%PNGOutput{}`.
  """

  @behaviour Fractals.OutputParser

  @computed_fields [:filename, :pid]

  @valid_extensions ~w(.png)
  @output_extension ".png"

  @impl Fractals.OutputParser
  def parse(params) do
    Enum.reduce(params, %PNGOutput{}, &parse_attribute/2)
  end

  @impl Fractals.OutputParser
  def compute(job) do
    Enum.reduce(@computed_fields, job.output, &compute_attribute(&1, &2, job))
  end

  defp parse_attribute({attribute, value}, output) do
    %{output | attribute => parse_value(attribute, value)}
  end

  defp parse_value(:type, "png") do
    :png
  end

  defp parse_value(attribute, value) when attribute in [:directory, :filename, :max_intensity] do
    value
  end

  defp compute_attribute(attribute, output, job) do
    %{output | attribute => compute_value(attribute, output, job)}
  end

  defp compute_value(:filename, output, job) do
    cond do
      output.filename == nil ->
        compute_filename(output, job)

      Path.extname(output.filename) in @valid_extensions ->
        Path.join(output.directory, output.filename)

      true ->
        {:error, "invalid extension #{output.filename}"}
    end
  end

  defp compute_value(:pid, output, _job) do
    with filename when is_binary(filename) <- output.filename,
         {:ok, pid} <- File.open(output.filename, [:write]) do
      pid
    end
  end

  defp compute_filename(output, job) do
    case job.params_filenames do
      [] ->
        nil

      [filename | _] ->
        output_basepath(filename, output) <> @output_extension
    end
  end

  @spec output_basepath(String.t(), Fractals.Output.t()) :: String.t()
  defp output_basepath(filename, output) do
    Path.join(output.directory, basename(filename))
  end

  @spec basename(String.t()) :: String.t()
  defp basename(filename) do
    (~w(.yml) ++ @valid_extensions)
    |> Enum.reduce(filename, fn ext, f -> Path.basename(f, ext) end)
  end
end
