defmodule Fractals.OutputMockSupport do
  @moduledoc """
  Support functions for settings expectations on `Fractals.OutputMock`.

  Output is separated with single space: `" START!"`, `" CLOSE!"`, etc.  This makes reading the tests a bit easier.
  """

  import Mox

  alias Fractals.Job
  alias Fractals.Output.OutputState

  @doc """
  Sets expectations on `Fractals.Output.open/1`.

  * A `Fractals.Job` must be passed to `open/1`.
  * "OPEN!" will be written to `pid`.  (NOTE: _no_ space!)
  * The `pid` will be returned by the mocked function (to be set in an `Fractals.Output.OutputParser`.)

  Use `StringIO` to create the pid for easier testing.
  """
  @spec expect_open(module(), pid()) :: module()
  def expect_open(mock, pid) do
    expect(mock, :open, fn %Job{} ->
      IO.write(pid, "OPEN!")
      pid
    end)
  end

  @doc """
  Sets expectations on `Fractals.Output.start/1`.

  * The first argument passed to `start/1` must be an `OutputState`.
  * `" START!" will be written to the `pid` passed to `expect_open/2`.
  """
  @spec expect_start(module()) :: module()
  def expect_start(mock) do
    expect(mock, :start, &write(&1, "START!"))
  end

  @doc """
  Allows `Fractals.Output.write/2` to be called as many times as needed.

  * The first argument must be an `OutputState`.
  * The second argument is written to the `pid` passed to `expect_open/2`.
  """
  @spec stub_write(module()) :: module()
  def stub_write(mock) do
    stub(mock, :write, &write/2)
  end

  @doc """
  Sets expectations on `Fractals.Output.write/2`.

  * The first argument must be an `OutputState`.
  * The second argument is a list of "pixels" (which for testing reasons can be any datatype).
  * The third argument is written (with a leading space) to the `pid` passed to `expect_open/2`.
  """
  @spec expect_write(module(), list(any()), String.t()) :: module()
  def expect_write(mock, pixels, output) do
    expect(mock, :write, fn state, ^pixels -> write(state, output) end)
  end

  @doc """
  Sets expectations on `Fractals.Output.stop/1`.

  * The first argument passed to `stop/1` must be an `OutputState`.
  * `" STOP!" will be written to the `pid` passed to `expect_open/2`.
  """
  @spec expect_stop(module()) :: module()
  def expect_stop(mock) do
    expect(mock, :stop, &write(&1, "STOP!"))
  end

  @doc """
  Sets expectations on `Fractals.Output.close/1`.

  * The first argument passed to `close/1` must be an `OutputState`.
  * `" CLOSE!" will be written to the `pid` passed to `expect_open/2`.
  """
  @spec expect_close(module()) :: module()
  def expect_close(mock) do
    expect(mock, :close, &write(&1, "CLOSE!"))
  end

  defp write(%OutputState{pid: pid} = state, message) do
    IO.write(pid, " #{message}")
    state
  end
end
