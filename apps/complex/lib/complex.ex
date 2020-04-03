defmodule Complex do
  @moduledoc """
  A local abstraction for complex numbers.

  The two libraries in hex for complex numbers disappointment me.  So I wrote
  the boundary layer so that I can switch implementations quickly.  And provide
  my own implementation.
  """

  @type t :: %ComplexNum{real: float(), imaginary: float()}

  defdelegate new(real), to: ComplexNum
  defdelegate new(real, imag), to: ComplexNum

  @doc """
  Parses a complex number from a string.

  ## Examples

      iex> assert Complex.parse("1.1+2.2i") == Complex.new(1.1, 2.2)
      iex> assert Complex.parse("-1.1+-2.2i") == Complex.new(-1.1, -2.2)

  """
  @spec parse(String.t()) :: t()
  def parse(str) do
    [_, real, imag] = Regex.run(~r/([-]?\d+\.\d+)\+([-]?\d+\.\d+)i/, str)

    ComplexNum.new(String.to_float(real), String.to_float(imag))
  end

  @doc """
      iex> Complex.real(Complex.new(5.0, 1.0))
      5.0
  """
  @spec real(t()) :: float()
  def real(%ComplexNum{real: real}), do: real

  @doc """
      iex> Complex.imag(Complex.new(5.0, 1.0))
      1.0
  """
  @spec imag(t()) :: float()
  def imag(%ComplexNum{imaginary: imag}), do: imag

  @doc """
      iex> z0 = Complex.new(1.0, 2.0)
      iex> z1 = Complex.new(50.0, 60.0)
      iex> assert Complex.add(z0, z1) == Complex.new(51.0, 62.0)
  """
  defdelegate add(z0, z1), to: ComplexNum

  @doc """
      iex> Complex.new(3.0, 4.0) |> Complex.magnitude_squared()
      25.0
  """
  defdelegate magnitude_squared(z), to: ComplexNum

  @doc """
      iex> assert Complex.new(3.0, 4.0) |> Complex.square() == Complex.new(-7.0, 24.0)
  """
  def square(z) do
    ComplexNum.pow(z, 2)
  end
end
