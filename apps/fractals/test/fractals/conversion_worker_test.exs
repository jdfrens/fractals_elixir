defmodule Fractals.ConversionWorkerTest do
  use ExUnit.Case, async: true

  alias Fractals.ConversionWorker
  alias Fractals.Job

  setup do
    test_pid = self()
    convert = fn source, destination -> send(test_pid, {source, destination}) end
    broadcast = fn tag, job, opts -> send(test_pid, {:test_report, {tag, job, opts}}) end

    {:ok, pid} =
      ConversionWorker.start_link(
        convert: convert,
        broadcast: broadcast,
        name: :conversion_worker_under_test
      )

    [pid: pid]
  end

  describe "&convert/1" do
    test "reports done for a PPM file", %{pid: pid} do
      job = %Job{output_filename: "output.ppm"}
      ConversionWorker.convert(pid, job)

      assert_receive {:test_report, {:done, _pid, _job}}
    end

    test "calls converter and reports done for a PNG file", %{pid: pid} do
      job = %Job{output_filename: "output.png"}
      ConversionWorker.convert(pid, job)

      assert_receive {"output.ppm", "output.png"}
      assert_receive {:test_report, {:done, _pid, _job}}
    end
  end
end
