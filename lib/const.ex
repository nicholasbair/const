defmodule Const do
  @moduledoc """
  Wrapper for accessing env variables and converting from a string to the correct type
  """

  @doc ~S"""

  ## Examples

      iex> Const.fetch!("NOT_THERE")
      ** (RuntimeError) Env variable error, no value found for NOT_THERE.

      iex> Const.fetch!("NOT_THERE", :string)
      ** (RuntimeError) Env variable error, no value found for NOT_THERE.

      iex> System.put_env("STRING", "string")
      iex> str = Const.fetch("STRING")
      iex> is_bitstring(str)
      true

      iex> System.put_env("STRING", "string")
      iex> str = Const.fetch("STRING", :string)
      iex> is_bitstring(str)
      true

      iex> System.put_env("ACCT", "000-000-000")
      iex> acct = Const.fetch("ACCT")
      iex> is_bitstring(acct)
      true

      iex> System.put_env("ACCT", "000-000-000")
      iex> acct = Const.fetch("ACCT", :string)
      iex> is_bitstring(acct)
      true

      iex> System.put_env("INT", "123")
      iex> int = Const.fetch("INT")
      iex> is_integer(int)
      true

      iex> System.put_env("INT", "123")
      iex> int = Const.fetch("INT", :integer)
      iex> is_integer(int)
      true

      iex> System.put_env("NEG_INT", "-123")
      iex> int = Const.fetch("NEG_INT")
      iex> is_integer(int)
      true

      iex> System.put_env("NEG_INT", "-123")
      iex> int = Const.fetch("NEG_INT", :integer)
      iex> is_integer(int)
      true

      iex> System.put_env("FLOAT", "1.23")
      iex> flt = Const.fetch("FLOAT")
      iex> is_float(flt)
      true

      iex> System.put_env("FLOAT", "1.23")
      iex> flt = Const.fetch("FLOAT", :float)
      iex> is_float(flt)
      true

      iex> System.put_env("NEG_FLOAT", "-1.23")
      iex> flt = Const.fetch("NEG_FLOAT")
      iex> is_float(flt)
      true

      iex> System.put_env("NEG_FLOAT", "-1.23")
      iex> flt = Const.fetch("NEG_FLOAT", :float)
      iex> is_float(flt)
      true

      iex> System.put_env("BOOL", "true")
      iex> bool = Const.fetch("BOOL")
      iex> is_boolean(bool)
      true

      iex> System.put_env("BOOL", "true")
      iex> bool = Const.fetch("BOOL", :boolean)
      iex> is_boolean(bool)
      true

      iex> System.put_env("JSON", "{\"testing\": \"things\"}")
      iex> json = Const.fetch("JSON")
      iex> is_map(json)
      true

      iex> System.put_env("JSON", "{\"testing\": \"things\"}")
      iex> json = Const.fetch("JSON", :map)
      iex> is_map(json)
      true
  """

  @spec fetch!(String.t()) :: boolean() | float() | integer() | String.t() | map()
  def fetch!(var) do
    var
    |> get!()
    |> convert()
  end

  @spec fetch(String.t()) :: nil | boolean() | float() | integer() | String.t() | map()
  def fetch(var) do
    var
    |> get()
    |> convert()
  end

  @spec fetch!(String.t(), atom()) :: nil | boolean() | float() | integer() | String.t() | map()
  def fetch!(var, type) do
    var
    |> get!()
    |> convert(type)
  end

  @spec fetch(String.t(), atom()) :: nil | boolean() | float() | integer() | String.t() | map()
  def fetch(var, type) do
    var
    |> get()
    |> convert(type)
  end

  # -- Private --
  @spec get(String.t()) :: nil | String.t()
  defp get(var) do
    var
    |> System.get_env
  end

  @spec get!(String.t()) :: String.t()
  defp get!(var) do
    case val = get(var) do
      nil -> raise "Env variable error, no value found for #{var}."
      _ -> val
    end
  end

  @spec convert(nil | String.t(), atom()) :: nil | boolean() | float() | integer() | String.t() | map()
  defp convert(nil, _type), do: nil
  defp convert(val, :string), do: val
  defp convert(val, :boolean), do: convert(val)
  defp convert(val, :map), do: convert_str(val)
  defp convert(val, type) when type in [:integer, :float, :atom, :existing_atom, :charlist] do
    apply(String, String.to_atom("to_#{type}"), [val])
  end

  @spec convert(nil | String.t()) :: nil | boolean() | float() | integer() | String.t() | map()
  defp convert(val) when val in ["true", "TRUE"], do: true
  defp convert(val) when val in ["false", "FALSE"], do: false
  defp convert(nil), do: nil

  defp convert(val) do
    case String.match?(val, ~r/[a-zA-Z]/) or String.match?(val, ~r/^[\d]+(-)+[\d]/) do
      true -> convert_str(val)
      false -> convert_num(val)
    end
  end

  @spec convert_num(String.t()) :: float() | integer()
  defp convert_num(val) do
    case String.match?(val, ~r/\d\./) do
      true -> String.to_float(val)
      false -> String.to_integer(val)
    end
  end

  @spec convert_str(String.t()) :: map() | String.t()
  defp convert_str(val) do
    case is_json?(val) do
      true -> Jason.decode!(val, [keys: :atoms])
      false -> val
    end
  end

  @spec is_json?(String.t()) :: boolean()
  defp is_json?(str), do: String.match?(str, ~r/{/)

end
