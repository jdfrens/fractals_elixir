defmodule PNG.ConfigTest do
  use ExUnit.Case, async: true

  import PNG.Consts

  # check_config() ->
  test "check config" do
    #     Config1 = #png_config{},
    #     ?assertEqual({error, invalid}, png:check_config(Config1)),
    config1 = %PNG.Config{}
    assert {:error, :invalid} = PNG.Config.check(config1)

    #     Config2 = #png_config{size = {0, 1}},
    #     ?assertEqual({error, invalid}, png:check_config(Config2)),
    config2 = %PNG.Config{size: {0, 1}}
    assert {:error, :invalid} = PNG.Config.check(config2)

    #     Config3 = #png_config{size = {1, 1}},
    #     ?assertEqual(ok, png:check_config(Config3)),
    config3 = %PNG.Config{size: {1, 1}}
    assert :ok = PNG.Config.check(config3)

    #     Config4 = #png_config{size = {1, 1}, mode = ?PNG_INDEXED_8},
    #     ?assertEqual(ok, png:check_config(Config4)).
    config4 = %PNG.Config{size: {1, 1}, mode: const(:png_indexed_8)}
    assert :ok = PNG.Config.check(config4)
  end
end
