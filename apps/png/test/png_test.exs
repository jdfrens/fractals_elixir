defmodule PNGTest do
  @moduledoc """
  Transliteration of https://github.com/yuce/png/blob/b6af0face98495f10fba3f638f1f36931ff2b3fe/test/png_tests.erl
  """

  use ExUnit.Case, async: true

  # NOTE: the `target` in this test is _not_ the same `Target` in the corresponding test in the original png library.
  # THE TEST IS BROKEN IN THE ORIGINAL png LIBRARY AND GIVES A FALSE POSITIVE.
  # I am asserting against the value that the original png library DOES compute (and so does my transliteration).
  # https://github.com/yuce/png/blob/b6af0face98495f10fba3f638f1f36931ff2b3fe/test/png_tests.erl#L38
  test "create/1 and append/2" do
    e = :ets.new(:state, [])

    cb = fn bin ->
      new_contents =
        case :ets.lookup(e, :contents) do
          [] ->
            [bin]

          [{_, contents}] ->
            [contents, bin]
        end

      true = :ets.insert(e, {:contents, list_to_binary(new_contents)})
      :ok
    end

    png =
      PNG.create(%{
        size: {4, 2},
        mode: {:indexed, 8},
        call: cb,
        palette: {:rgb, 8, [{255, 0, 0}, {0, 0, 255}]}
      })

    png = PNG.append(png, {:rows, [0, 1, 0, 1]})

    :ok = PNG.close(png)
    [{_, result}] = :ets.lookup(e, :contents)

    target =
      <<137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 4, 0, 0, 0, 2, 8,
        3, 0, 0, 0, 72, 118, 141, 81, 0, 0, 0, 6, 80, 76, 84, 69, 255, 0, 0, 0, 0, 255, 108, 161,
        253, 142, 0, 0, 0, 2, 73, 68, 65, 84, 120, 156, 98, 164, 145, 43, 0, 0, 0, 12, 73, 68, 65,
        84, 99, 96, 96, 96, 100, 0, 98, 0, 0, 14, 0, 3, 74, 42, 55, 187, 0, 0, 0, 0, 73, 69, 78,
        68, 174, 66, 96, 130>>

    assert target == result
  end

  def list_to_binary(io_list) do
    :erlang.list_to_binary(io_list)
  end
end
