defmodule PNG.ConfigTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias PNG.Config

  describe "check/1" do
    test "default is invalid" do
      config = %PNG{}
      assert {:error, :invalid} = Config.check(config)
    end

    test "width and height must be 1 or larger" do
      config = %PNG{size: {0, 1}}
      assert {:error, :invalid} = Config.check(config)
    end

    test "valid when size set properly" do
      config = %PNG{size: {1, 1}}
      assert :ok = Config.check(config)
    end

    test "valid with different mode" do
      config = %PNG{size: {1, 1}, mode: {:indexed, 8}}
      assert :ok = Config.check(config)
    end
  end
end
