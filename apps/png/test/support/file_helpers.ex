defmodule PNG.FileHelpers do
  @moduledoc """
  Support functions for managing image filenames.
  """

  @keep_files false

  @doc """
  Given a `:filename` in a context, generates `:image_filename` and
  `:expected_filename`.  Also does cleanup of the (generated) image file.

  To keep files after running tests, set `@keep_files` above to `true`.

  ```elixir
  setup do
    setup_filenames("common_filename.png")
  end
  ```
  """
  @spec setup_filenames(String.t()) :: {:ok, image_filename: String.t(), expected_filename: String.t()}
  def setup_filenames(filename) do
    image_filename = "test/images/" <> filename
    expected_filename = "test/expected_outputs/" <> filename

    unless @keep_files do
      :ok = delete_if_exists(image_filename)

      ExUnit.Callbacks.on_exit(fn ->
        delete_if_exists(image_filename)
      end)
    end

    {:ok, image_filename: image_filename, expected_filename: expected_filename}
  end

  @doc """
  Writes an image to a file during a test.

  Primary purpose of the function is to flip the order of the arguments.
  """
  @spec write_image_file(iodata(), String.t()) :: :ok
  def write_image_file(io_data, image_filename) do
    :ok = :file.write_file(image_filename, io_data)
  end

  defp delete_if_exists(filename) do
    if File.exists?(filename) do
      File.rm(filename)
    else
      :ok
    end
  end
end
