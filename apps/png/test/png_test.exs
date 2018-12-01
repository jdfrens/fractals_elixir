defmodule PNGTest do
  @moduledoc """
  Transliteration of https://github.com/yuce/png/blob/b6af0face98495f10fba3f638f1f36931ff2b3fe/test/png_tests.erl
  """

  use ExUnit.Case, async: true

  # -module(png_tests).

  # -include_lib("eunit/include/eunit.hrl").
  # -include_lib("png/include/png.hrl").

  # iface_test_() ->
  #     [fun create_append/0].

  # check_config_test_() ->
  #     [fun check_config/0].

  @tag :skip
  # create_append() ->
  test "create_append()" do
    #     E = ets:new(state, []),
    e = :ets.new(:state, [])

    #     Cb = fun(Bin) ->
    #             NewContents = case ets:lookup(E, contents) of
    #                                 [] ->
    #                                     [Bin];
    #                                 [{_, Contents}] ->
    #                                     [Contents, Bin] end,
    #         true = ets:insert(E, {contents, list_to_binary(NewContents)}),
    #         ok end,
    cb = fn bin ->
      new_contents =
        case :ets.lookup(e, :contents) do
          [] ->
            [bin]

          [{_, contents}] ->
            [contents, bin]
        end

      true = :ets.insert(e, {:contents, list_to_binary(new_contents)})
      :ok
    end

    #     Png = png:create(#{size => {4, 2},
    #                    mode => {indexed, 8},
    #                    call => Cb,
    #                    palette => {rgb, 8, [{255, 0, 0}, {0, 0, 255}]}}),
    png =
      PNG.create(
        PNG.config(
          size: {4, 2},
          mode: {:indexed, 8},
          call: cb,
          palette: {:rgb, 8, [{255, 0, 0}, {0, 0, 255}]}
        )
      )

    #     Png = png:append(Png, {rows, [0, 1, 0, 1]}),
    png = PNG.append(png, {:rows, [0, 1, 0, 1]})

    #     ok = png:close(Png),
    :ok = PNG.close(png)

    #     [{_, Result}] = ets:lookup(E, contents),
    [{_, result}] = :ets.lookup(e, :contents)

    #     Target = <<137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,4,0,0,0,2,
    #                8,3,0,0,0,
    #                72,118,141,81,0,0,0,6,80,76,84,69,255,0,0,0,0,255,108,161,253,
    #                142,0,0,0,
    #                14,73,68,65,84,120,156,99,96,96,96,100,0,98,0,0,14,0,3,216,95,
    #                69,48,0,0,0,0,73,69,78,68,174,66,96,130>>,
    target =
      <<137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 4, 0, 0, 0, 2, 8,
        3, 0, 0, 0, 72, 118, 141, 81, 0, 0, 0, 6, 80, 76, 84, 69, 255, 0, 0, 0, 0, 255, 108, 161,
        253, 142, 0, 0, 0, 14, 73, 68, 65, 84, 120, 156, 99, 96, 96, 96, 100, 0, 98, 0, 0, 14, 0,
        3, 216, 95, 69, 48, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130>>

    #     [?_assertEqual(Target, Result)].
    assert target == result
  end

  def list_to_binary(io_list) do
    :erlang.list_to_binary(io_list)
  end
end
