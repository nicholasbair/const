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

  def init do
    # fetch/1 will return nil if no value is present
    fetch("AN_ENV")
    |> use_value
  end

  def init(arg) do
    # fetch!/1 will raise an error if no value is present
    fetch!("AN_ENV)
    |> use_value
  end

end

```
