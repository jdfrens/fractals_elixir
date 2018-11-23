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
    Broadcaster.add_reporter(Countdown, %{params_list: args.params_list, for: self()})

    args
  end

  @spec fractalize(Args.t()) :: Args.t()
  defp fractalize(%Args{params_list: params_list} = args) do
    Enum.each(params_list, fn params ->
      Broadcaster.report(:starting, params, from: self())

      case Fractals.fractalize(params) do
        :ok ->
          :ok

        {:error, reason} ->
          Broadcaster.report(:skipping, params, reason: reason, from: self())
      end
    end)

    args
  end

  @spec wait(Args.t()) :: :ok
  def wait(_args) do
    receive do
      {:filenames_empty, _reason} ->
        IO.puts("ALL DONE!")
        IO.puts("Have a nice day.")
    end

    :ok
  end
end
