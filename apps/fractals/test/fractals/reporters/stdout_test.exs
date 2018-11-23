defmodule Fractals.Reporters.StdoutTest do
  use ExUnit.Case, async: true

  setup do
    test_process = self()
    puts = fn message -> send(test_process, message) end
    {:ok, pid} = start_supervised({Fractals.Reporters.Stdout, name: nil, puts: puts})

    {:ok, pid: pid}
  end

  test "handles :starting message", %{pid: pid} do
    GenServer.cast(pid, {:starting, %{output_filename: "output.png"}, []})

    assert_receive "starting output.png"
  end

  test "handles :skipping message", %{pid: pid} do
    GenServer.cast(pid, {:skipping, %{output_filename: "output.png"}, [reason: "because love"]})

    assert_receive "skipping output.png: because love"
  end

  test "handles :done message", %{pid: pid} do
    GenServer.cast(pid, {:done, %{output_filename: "output.png"}, []})

    assert_receive "finished output.png"
  end
end
