defmodule PNG.ConfigTest do
  use ExUnit.Case, async: true

  import PNG.Consts

  describe "check/1" do
    test "default is invalid" do
      config = %PNG.Config{}
      assert {:error, :invalid} = PNG.Config.check(config)
    end

    test "width and height must be 1 or larger" do
      config = %PNG.Config{size: {0, 1}}
      assert {:error, :invalid} = PNG.Config.check(config)
    end

    test "valid when size set properly" do
      config = %PNG.Config{size: {1, 1}}
      assert :ok = PNG.Config.check(config)
    end

    test "valid with different mode" do
      config = %PNG.Config{size: {1, 1}, mode: const(:png_indexed_8)}
      assert :ok = PNG.Config.check(config)
    end
  end
end
