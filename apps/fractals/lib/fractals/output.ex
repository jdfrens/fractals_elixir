defmodule Fractals.Output do
  @moduledoc """
  Represents  the output values for a job.
  """

  @type t :: %__MODULE__{
          directory: String.t() | nil,
          filename: String.t() | nil,
          ppm_filename: String.t() | nil,
          pid: pid() | nil
        }

  defstruct directory: "images", filename: nil, ppm_filename: nil, pid: nil

  # IDEA: this could be a param
  @output_extension ".png"

  def parse(params) do
    Enum.reduce(params, %__MODULE__{}, &parse_attribute/2)
  end

  defp parse_attribute({attribute, value}, output) do
    %{output | attribute => parse_value(attribute, value)}
  end

  defp parse_value(attribute, value) when attribute in [:directory, :filename, :ppm_filename] do
    value
  end

  def compute(job) do
    Enum.reduce([:filename, :ppm_filename, :pid], job.output, &compute_attribute(&1, &2, job))
  end

  defp compute_attribute(attribute, output, job) do
    %{output | attribute => compute_value(attribute, output, job)}
  end

  defp compute_value(:filename, output, job) do
    if output.filename == nil do
      case job.params_filenames do
        [] ->
          nil

        [filename] ->
          output_basepath(filename, output) <> @output_extension

        _ ->
          nil
      end
    else
      Path.join(output.directory, output.filename)
    end
  end

  defp compute_value(:ppm_filename, output, _job) do
    case output.filename do
      nil ->
        nil

      filename ->
        output_basepath(filename, output) <> ".ppm"
    end
  end

  defp compute_value(:pid, output, _job) do
    case output.ppm_filename do
      nil ->
        nil

      filename ->
        File.open!(filename, [:write])
    end
  end

  @spec output_basepath(String.t(), Fractals.Output.t()) :: String.t()
  defp output_basepath(filename, output) do
    Path.join(output.directory, basename(filename))
  end

  @spec basename(String.t()) :: String.t()
  defp basename(filename) do
    filename
    |> Path.basename(".yml")
    |> Path.basename(".png")
    |> Path.basename(".ppm")
  end
end
