defmodule Fractals.OutputWorkerTest do
  @moduledoc false

  use ExUnit.Case, async: true

  import Mox
  import Fractals.OutputMockSupport

  alias Fractals.Reporters.{Broadcaster, Countdown}
  alias Fractals.{Chunk, Image, Job, Size}
  alias Fractals.OutputWorker

  setup :verify_on_exit!

  setup do
    {:ok, output_pid} = StringIO.open("")
    {:ok, worker} = OutputWorker.start_link(:output_worker_test)

    allow(Fractals.OutputMock, self(), worker)

    {:ok, output_pid: output_pid, worker: worker}
  end

  describe "write/2" do
    setup %{output_pid: output_pid} do
      job = %Job{
        output: %{pid: output_pid, module: Fractals.OutputMock, max_intensity: 255},
        image: %Image{size: %Size{width: 3, height: 1}},
        engine: %{chunk_count: 3}
      }

      {:ok, job: job}
    end

    setup %{job: job} do
      Broadcaster.add_reporter(Countdown, %{jobs: [job], for: self()})
      :ok
    end

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
end
