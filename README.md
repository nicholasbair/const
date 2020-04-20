# Const

Get values from environment variables and convert the value to the proper data type.

Built to work with Heroku, other systems have not been tested.

## Installation

```elixir
def deps do
  [
    {:const, git: "https://github.com/nicholasbair/const.git"}
  ]
end
```

## Usage

```elixir

defmodule MyModule do

  import Const

  # Implicit type conversion
  def init do
    # fetch/1 will return nil if no value is present
    fetch("AN_ENV")
    |> use_value
  end

  # Implicit type conversion
  def init(arg) do
    # fetch!/1 will raise an error if no value is present
    fetch!("AN_ENV")
    |> use_value
  end

  # Explicit type conversion
  def init do
    # fetch/2 will return nil if no value is present
    fetch("AN_ENV", :integer)
    |> use_value
  end

  # Explicit type conversion
  def init(arg) do
    # fetch!/2 will raise an error if no value is present
    fetch!("AN_ENV", :integer)
    |> use_value
  end

end

```
