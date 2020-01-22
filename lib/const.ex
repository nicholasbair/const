defmodule Const do
  @moduledoc """
  Wrapper for accessing env variables and converting from a string to the correct type
  """

  @doc ~S"""

  ## Examples

      iex> Const.fetch!("NOT_THERE")
      ** (RuntimeError) Env variable error, no value found for NOT_THERE.

      iex> System.put_env("STRING", "string")
      iex> str = Const.fetch("STRING")
      iex> is_bitstring(str)
      true

      iex> System.put_env("ACCT", "000-000-000")
      iex> acct = Const.fetch("ACCT")
      iex> is_bitstring(acct)
      true

      iex> System.put_env("INT", "123")
      iex> int = Const.fetch("INT")
      iex> is_integer(int)
      true

      iex> System.put_env("NEG_INT", "-123")
      iex> int = Const.fetch("NEG_INT")
      iex> is_integer(int)
      true

      iex> System.put_env("FLOAT", "1.23")
      iex> flt = Const.fetch("FLOAT")
      iex> is_float(flt)
      true

      iex> System.put_env("NEG_FLOAT", "-1.23")
      iex> flt = Const.fetch("NEG_FLOAT")
      iex> is_float(flt)
      true

      iex> System.put_env("BOOL", "true")
      iex> bool = Const.fetch("BOOL")
      iex> is_boolean(bool)
      true

      iex> System.put_env("JSON", "{\"testing\": \"things\"}")
      iex> json = Const.fetch("JSON")
      iex> is_map(json)
      true
  """

  @spec fetch!(String.t) :: boolean | float | integer | String.t | map
  def fetch!(var) do
    case val = fetch(var) do
      nil -> raise "Env variable error, no value found for #{var}."
      _ -> val
    end
  end

  @spec fetch(String.t) :: nil | boolean | float | integer | String.t | map
  def fetch(var) do
    var
    |> System.get_env
    |> convert(var)
  end

  # -- Private --
  @spec convert(nil | String.t, String.t) :: nil | boolean | float | integer | String.t | map
  defp convert(val, _var) when val in ["true", "TRUE"], do: true
  defp convert(val, _var) when val in ["false", "FALSE"], do: false
  defp convert(nil, _var), do: nil

  defp convert(val, _var) do
    case String.match?(val, ~r/[a-zA-Z]/) or String.match?(val, ~r/^[\d]+(-)+[\d]/) do
      true -> convert_str(val)
      false -> convert_num(val)
    end
  end

  @spec convert_num(String.t) :: float | integer
  defp convert_num(val) do
    case String.match?(val, ~r/\d\./) do
      true -> String.to_float(val)
      false -> String.to_integer(val)
    end
  end

  @spec convert_str(String.t) :: map | String.t
  defp convert_str(val) do
    case is_json?(val) do
      true -> Jason.decode!(val)
      false -> val
    end
  end

  @spec is_json?(String.t) :: boolean
  defp is_json?(str), do: String.match?(str, ~r/{/)

end
