defmodule Fractals.Output.WorkerCacheTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use ExUnitProperties

  import Mox
  import Fractals.OutputMockSupport

  alias Fractals.Chunk
  alias Fractals.Output.{OutputState, WorkerCache}

  setup :verify_on_exit!

  describe "next_chunk/2" do
    property "chunks come in any order, cache writes in order" do
      check all list <- list_of(string(?a..?z, length: 0..500)),
                length(list) > 0 do
        chunks =
          list
          |> Enum.zip(1..501)
          |> Enum.sort()
          |> Enum.map(fn {data, number} ->
            %Chunk{number: number, data: data}
          end)

        {:ok, pid} = StringIO.open("")

        state = %OutputState{
          pid: pid,
          output_module: Fractals.OutputMock,
          next_number: 1,
          cache: WorkerCache.new(length(list))
        }

        Fractals.OutputMock
        |> stub_write()
        |> expect_stop()
        |> expect_close()

        assert %OutputState{cache: %{}} =
                 Enum.reduce(chunks, state, &WorkerCache.next_chunk(&2, &1))

        expected_pixels = Enum.join(list, " ")
        assert {"", " #{expected_pixels} STOP! CLOSE!"} == StringIO.contents(pid)
      end
    end
  end
end
