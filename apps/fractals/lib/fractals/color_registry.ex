defmodule Fractals.ColorRegistry do
  @moduledoc """
  Registry for colors.

  `Fractals.Color` does it's own "polymorphism", and it's easier to just return the sane class.  This registry makes
  it's interface look like the other interfaces (which is good for parsing a `Fractals.Job`).
  """

  def get(_type) do
    Fractals.Color
  end

  def add(_, _) do
    nil
  end
end
