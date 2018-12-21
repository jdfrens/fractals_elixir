defmodule Fractals.OutputWorkerTest do
  @moduledoc false

  use ExUnit.Case, async: true

  import Mox

  setup :verify_on_exit!

  alias Fractals.Reporters.{Broadcaster, Countdown}
  alias Fractals.{Chunk, Image, Job, Size}
  alias Fractals.Output.OutputState
  alias Fractals.OutputWorker

  setup do
    {:ok, output_pid} = StringIO.open("")
    {:ok, worker} = OutputWorker.start_link(:output_worker_test)

    allow(Fractals.OutputMock, self(), worker)

    [output_pid: output_pid, worker: worker]
  end

  describe "when sending one chunk" do
    setup [:chunk_count_1, :job]

    test "writing a chunk", %{worker: worker, output_pid: output_pid, job: job} do
      Fractals.OutputMock
      |> expect_open(output_pid)
      |> expect_start()
      |> expect_write(["a", "b", "c"], "chunk1")
      |> expect_stop()
      |> expect_close()

      OutputWorker.write(worker, %Chunk{number: 1, data: ["a", "b", "c"], job: job})

      assert_receive {:jobs_countdown_done, _reason}, 500
      assert StringIO.contents(output_pid) == {"", "OPEN! START! chunk1 STOP! CLOSE!"}
    end
  end

  describe "when sending multiple chunks" do
    setup [:chunk_count_3, :job]

    test "writes multiple chunks", %{worker: worker, output_pid: output_pid, job: job} do
      Fractals.OutputMock
      |> expect_open(output_pid)
      |> expect_start()
      |> expect_write(["a"], "chunk1")
      |> expect_write(["m"], "chunk2")
      |> expect_write(["x"], "chunk3")
      |> expect_stop()
      |> expect_close()

      OutputWorker.write(worker, %Chunk{number: 1, data: ["a"], job: job})
      OutputWorker.write(worker, %Chunk{number: 2, data: ["m"], job: job})
      OutputWorker.write(worker, %Chunk{number: 3, data: ["x"], job: job})

      assert_receive {:jobs_countdown_done, _reason}, 500

      assert StringIO.contents(output_pid) ==
               {"", "OPEN! START! chunk1 chunk2 chunk3 STOP! CLOSE!"}
    end

    test "writes multiple chunks received out of order", %{
      worker: worker,
      output_pid: output_pid,
      job: job
    } do
      Fractals.OutputMock
      |> expect_open(output_pid)
      |> expect_start()
      |> expect_write(["a"], "chunk1")
      |> expect_write(["m"], "chunk2")
      |> expect_write(["x"], "chunk3")
      |> expect_stop()
      |> expect_close()

      OutputWorker.write(worker, %Chunk{number: 2, data: ["m"], job: job})
      OutputWorker.write(worker, %Chunk{number: 3, data: ["x"], job: job})
      OutputWorker.write(worker, %Chunk{number: 1, data: ["a"], job: job})

      assert_receive {:jobs_countdown_done, _reason}, 500

      assert StringIO.contents(output_pid) ==
               {"", "OPEN! START! chunk1 chunk2 chunk3 STOP! CLOSE!"}
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

    Broadcaster.add_reporter(Countdown, %{jobs: [job], for: self()})

    [job: job]
  end

  defp expect_open(mock, pid) do
    expect(mock, :open, fn %Job{} ->
      IO.write(pid, "OPEN!")
      pid
    end)
  end

  defp expect_start(mock) do
    expect(mock, :start, &write(&1, "START!"))
  end

  defp expect_write(mock, pixels, output) do
    expect(mock, :write, fn state, ^pixels -> write(state, output) end)
  end

  defp expect_stop(mock) do
    expect(mock, :stop, &write(&1, "STOP!"))
  end

  defp expect_close(mock) do
    expect(mock, :close, &write(&1, "CLOSE!"))
  end

  defp write(%OutputState{pid: pid} = state, message) do
    IO.write(pid, " #{message}")
    state
  end
end
