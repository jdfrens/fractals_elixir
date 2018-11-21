defmodule UniprocessEngine do
  @moduledoc """
  Documentation for UniprocessEngine.
  """


  defdelegate generate(params), to: UniprocessEngine.Algorithm
end
