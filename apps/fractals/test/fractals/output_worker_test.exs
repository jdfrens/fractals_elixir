defmodule Fractals.OutputWorkerTest do
  @moduledoc false

  use ExUnit.Case, async: true

  import Mox

  setup :verify_on_exit!

  alias Fractals.{Chunk, Image, Job, Size}
  alias Fractals.OutputWorker

  setup do
    test_pid = self()
    next_stage = fn _job -> send(test_pid, :sent_to_next_stage) end
    {:ok, output_pid} = StringIO.open("")
    {:ok, subject} = OutputWorker.start_link({next_stage, :whatever})

    allow(Fractals.OutputMock, self(), subject)

    [output_pid: output_pid, subject: subject]
  end

  describe "when sending one chunk" do
    setup [:chunk_count_1, :job]

    test "writing a chunk", %{subject: subject, output_pid: output_pid, job: job} do
      Fractals.OutputMock
      |> expect(:start_file, fn ^job -> IO.write(output_pid, "START!") end)
      |> expect(:write_pixels, fn ^job, ["a", "b", "c"] -> IO.write(output_pid, " chunk1") end)

      OutputWorker.write(subject, %Chunk{number: 1, data: ["a", "b", "c"], job: job})

      assert_receive :sent_to_next_stage, 500
      assert StringIO.contents(output_pid) == {"", "START! chunk1"}
    end
  end

  describe "when sending multiple chunks" do
    setup [:chunk_count_3, :job]

    test "writes multiple chunks", %{subject: subject, output_pid: output_pid, job: job} do
      Fractals.OutputMock
      |> expect(:start_file, fn ^job -> IO.write(output_pid, "START!") end)
      |> expect(:write_pixels, fn ^job, ["a"] -> IO.write(output_pid, " chunk1") end)
      |> expect(:write_pixels, fn ^job, ["m"] -> IO.write(output_pid, " chunk2") end)
      |> expect(:write_pixels, fn ^job, ["x"] -> IO.write(output_pid, " chunk3") end)

      OutputWorker.write(subject, %Chunk{number: 1, data: ["a"], job: job})
      OutputWorker.write(subject, %Chunk{number: 2, data: ["m"], job: job})
      OutputWorker.write(subject, %Chunk{number: 3, data: ["x"], job: job})

      assert_receive :sent_to_next_stage, 500
      assert StringIO.contents(output_pid) == {"", "START! chunk1 chunk2 chunk3"}
    end

    test "writes multiple chunks received out of order", %{
      subject: subject,
      output_pid: output_pid,
      job: job
    } do
      Fractals.OutputMock
      |> expect(:start_file, fn ^job -> IO.write(output_pid, "START!") end)
      |> expect(:write_pixels, fn ^job, ["a"] -> IO.write(output_pid, " chunk1") end)
      |> expect(:write_pixels, fn ^job, ["m"] -> IO.write(output_pid, " chunk2") end)
      |> expect(:write_pixels, fn ^job, ["x"] -> IO.write(output_pid, " chunk3") end)

      OutputWorker.write(subject, %Chunk{number: 2, data: ["m"], job: job})
      OutputWorker.write(subject, %Chunk{number: 3, data: ["x"], job: job})
      OutputWorker.write(subject, %Chunk{number: 1, data: ["a"], job: job})

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
