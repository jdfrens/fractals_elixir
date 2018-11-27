defmodule Fractals.GridTest do
  use ExUnit.Case, async: true

  alias Fractals.Grid
  alias Fractals.{Image, Job}

  def job do
    %Job{
      image: %Image{
        size: %Fractals.Size{width: 2, height: 3},
        upper_left: Complex.new(-1.0, 1.0),
        lower_right: Complex.new(1.0, -1.0)
      }
    }
  end

  describe ".chunk" do
    test "chunking evenly" do
      job = %Job{engine: %{chunk_size: 3, chunk_count: 2}}
      chunks = [:a, :b, :c, :d, :e, :f] |> Grid.chunk(job) |> Enum.to_list()

      assert chunks == [
               %Fractals.Chunk{number: 1, data: [:a, :b, :c], job: job},
               %Fractals.Chunk{number: 2, data: [:d, :e, :f], job: job}
             ]
    end

    test "chunking unevenly" do
      job = %Job{engine: %{chunk_size: 3, chunk_count: 2}}
      chunks = [:a, :b, :c, :xyz] |> Grid.chunk(job) |> Enum.to_list()

      assert chunks == [
               %Fractals.Chunk{number: 1, data: [:a, :b, :c], job: job},
               %Fractals.Chunk{number: 2, data: [:xyz], job: job}
             ]
    end
  end

  describe ".grid" do
    test "generate a grid" do
      assert Grid.grid(job()) == [
               Complex.new(-1.0, 1.0),
               Complex.new(1.0, 1.0),
               Complex.new(-1.0, 0.0),
               Complex.new(1.0, 0.0),
               Complex.new(-1.0, -1.0),
               Complex.new(1.0, -1.0)
             ]
    end
  end

  describe ".xs" do
    test "generate left-right based on corners and width" do
      assert Grid.xs(job().image) == [-1.0, 1.0]
    end
  end

  describe ".ys" do
    test "generate top-down based on corners and height" do
      assert Grid.ys(job().image) == [1.0, 0.0, -1.0]
    end
  end

  describe ".float_sequence" do
    test "generate a sequence" do
      assert Grid.float_sequence(3, -1.0, 1.0) == [-1.0, 0.0, 1.0]
    end

    test "generate the number of requested elements" do
      assert Grid.float_sequence(5, -2.0, 3.0) == [-2.0, -0.75, 0.5, 1.75, 3.0]
    end

    test "sequencing down" do
      assert Grid.float_sequence(3, 1.0, -1.0) == [1.0, 0.0, -1.0]
    end
  end
end
