defmodule Fractals.OutputWorkerTest do
  @moduledoc false

  use ExUnit.Case, async: true

  import Mox

  setup :verify_on_exit!

  alias Fractals.{Chunk, Image, Job, Size}
  alias Fractals.Output.OutputState
  alias Fractals.OutputWorker

  setup do
    test_pid = self()
    next_stage = fn _job -> send(test_pid, :sent_to_next_stage) end
    {:ok, output_pid} = StringIO.open("")
    {:ok, worker} = OutputWorker.start_link({next_stage, :whatever})

    allow(Fractals.OutputMock, self(), worker)

    [output_pid: output_pid, worker: worker]
  end

  describe "when sending one chunk" do
    setup [:chunk_count_1, :job]

    test "writing a chunk", %{worker: worker, output_pid: output_pid, job: job} do
      test_pid = self()

      Fractals.OutputMock
      |> expect(:start, fn ^job -> IO.write(output_pid, "START!") end)
      |> expect(:write, fn ^job, _, ["a", "b", "c"] -> IO.write(output_pid, " chunk1") end)
      |> expect(:stop, fn %OutputState{} -> send(test_pid, :stopped) end)

      OutputWorker.write(worker, %Chunk{number: 1, data: ["a", "b", "c"], job: job})

      assert_receive :stopped, 500
      assert_receive :sent_to_next_stage, 500
      assert StringIO.contents(output_pid) == {"", "START! chunk1"}
    end
  end

  describe "when sending multiple chunks" do
    setup [:chunk_count_3, :job]

    test "writes multiple chunks", %{worker: worker, output_pid: output_pid, job: job} do
      test_pid = self()

      Fractals.OutputMock
      |> expect(:start, fn ^job -> IO.write(output_pid, "START!") end)
      |> expect(:write, fn ^job, _, ["a"] -> IO.write(output_pid, " chunk1") end)
      |> expect(:write, fn ^job, _, ["m"] -> IO.write(output_pid, " chunk2") end)
      |> expect(:write, fn ^job, _, ["x"] -> IO.write(output_pid, " chunk3") end)
      |> expect(:stop, fn %OutputState{} -> send(test_pid, :stopped) end)

      OutputWorker.write(worker, %Chunk{number: 1, data: ["a"], job: job})
      OutputWorker.write(worker, %Chunk{number: 2, data: ["m"], job: job})
      OutputWorker.write(worker, %Chunk{number: 3, data: ["x"], job: job})

      assert_receive :stopped, 500
      assert_receive :sent_to_next_stage, 500
      assert StringIO.contents(output_pid) == {"", "START! chunk1 chunk2 chunk3"}
    end

    test "writes multiple chunks received out of order", %{
      worker: worker,
      output_pid: output_pid,
      job: job
    } do
      test_pid = self()

      Fractals.OutputMock
      |> expect(:start, fn ^job -> IO.write(output_pid, "START!") end)
      |> expect(:write, fn ^job, _, ["a"] -> IO.write(output_pid, " chunk1") end)
      |> expect(:write, fn ^job, _, ["m"] -> IO.write(output_pid, " chunk2") end)
      |> expect(:write, fn ^job, _, ["x"] -> IO.write(output_pid, " chunk3") end)
      |> expect(:stop, fn %OutputState{} -> send(test_pid, :stopped) end)

      OutputWorker.write(worker, %Chunk{number: 2, data: ["m"], job: job})
      OutputWorker.write(worker, %Chunk{number: 3, data: ["x"], job: job})
      OutputWorker.write(worker, %Chunk{number: 1, data: ["a"], job: job})

      assert_receive :stopped, 500
      assert_receive :sent_to_next_stage, 500
      assert StringIO.contents(output_pid) == {"", "START! chunk1 chunk2 chunk3"}
    end
  end

  defp chunk_count_1(_context), do: [chunk_count: 1]
  defp chunk_count_3(_context), do: [chunk_count: 3]

  defp job(context) do
    job = %Job{
      output: %{
        pid: context.output_pid,
        module: Fractals.OutputMock
      },
      image: %Image{
        size: %Size{width: 3, height: 1}
      },
      engine: %{
        chunk_count: context.chunk_count
      }
    }

    [job: job]
  end
end
