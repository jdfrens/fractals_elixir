defmodule CLI do
  @moduledoc """
  The command-line interface for generating fractals.  This also starts up the application itself.
  """

  alias CLI.Args
  alias Fractals.Reporters.{Broadcaster, Countdown, Stdout}

  @spec main(OptionParser.argv()) :: :ok
  def main(args) do
    args
    |> Args.process()
    |> add_reporters()
    |> fractalize()
    |> wait()
  end

  @spec add_reporters(Args.t()) :: Args.t()
  defp add_reporters(args) do
    Broadcaster.add_reporter(Stdout)
    Broadcaster.add_reporter(Countdown, %{jobs: args.jobs, for: self()})

    args
  end

  @spec fractalize(Args.t()) :: Args.t()
  defp fractalize(%Args{jobs: jobs} = args) do
    Enum.each(jobs, fn job ->
      Broadcaster.report(:starting, job, from: self())

      case Fractals.fractalize(job) do
        :ok ->
          :ok

        {:error, reason} ->
          Broadcaster.report(:skipping, job, reason: reason, from: self())
      end
    end)

    args
  end

  @spec wait(Args.t()) :: :ok
  def wait(_args) do
    receive do
      {:jobs_countdown_done, _reason} ->
        IO.puts("ALL DONE!")
        IO.puts("Have a nice day.")
    end

    :ok
  end
end
