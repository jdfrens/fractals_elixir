defmodule CLI.ArgsTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias CLI.Args

  @no_errors []

  describe "to_struct/2" do
    test "generates a valid struct" do
      argv = ["one", "two", "three"]

      assert %CLI.Args{
               valid?: true,
               argv: ^argv,
               errors: []
             } = Args.to_struct(argv, [])
    end

    test "invalid when there are errors" do
      argv = ["one", "two", "three"]

      assert %CLI.Args{
               valid?: false,
               argv: ^argv,
               errors: ["error"]
             } = Args.to_struct(argv, ["error"])
    end
  end

  describe "parse_filename_groups" do
    test "parses no groups" do
      args = Args.to_struct([], @no_errors)

      assert %Args{
               raw_params_list: []
             } = Args.parse_filename_groups(args)
    end

    test "parses one group" do
      args = Args.to_struct(["one"], @no_errors)

      assert %Args{
               raw_params_list: [[params_filename: "one"]]
             } = Args.parse_filename_groups(args)
    end

    test "parses many groups" do
      args = Args.to_struct(["one", "two", "three"], @no_errors)

      assert %Args{
               raw_params_list: [
                 [params_filename: "one"],
                 [params_filename: "two"],
                 [params_filename: "three"]
               ]
             } = Args.parse_filename_groups(args)
    end

    test "parses the individual groups" do
      argv = [
        "one,two",
        "three",
        "four,five,six"
      ]

      args = Args.to_struct(argv, @no_errors)

      assert %Args{
               raw_params_list: [
                 [params_filename: "one", params_filename: "two"],
                 [params_filename: "three"],
                 [
                   params_filename: "four",
                   params_filename: "five",
                   params_filename: "six"
                 ]
               ]
             } = Args.parse_filename_groups(args)
    end
  end
end
