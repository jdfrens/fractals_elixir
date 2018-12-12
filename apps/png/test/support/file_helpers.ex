defmodule PNG.FileHelpers do
  @moduledoc """
  Support functions for managing image filenames.
  """

  @keep_files false

  @doc """
  Given a `:filename` in a context, generates `:image_filename` and `:expected_filename`.  Also does cleanup of the
  (generated) image file.

  To keep files after running tests, set `@keep_files` above to `true`.

  ```elixir
  setup do
    setup_filenames("common_filename.png")
  end
  ```
  """
  def setup_filenames(filename) do
    image_filename = "test/images/" <> filename
    expected_filename = "test/expected_outputs/" <> filename

    unless @keep_files do
      delete_if_exists(image_filename)

      ExUnit.Callbacks.on_exit(fn ->
        delete_if_exists(image_filename)
      end)
    end

    {:ok, image_filename: image_filename, expected_filename: expected_filename}
  end

  defp delete_if_exists(filename) do
    if File.exists?(filename) do
      File.rm(filename)
    else
      :ok
    end
  end
end
