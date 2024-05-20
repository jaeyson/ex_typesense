defmodule Mix.Tasks.Typesense.Import do
  use Mix.Task

  @moduledoc since: "0.4.0"
  @moduledoc """
  ## Usage

  `mix typesense.import MODULE_NAME`

  Imports an Ecto schema with/or records to a collection.

  To view this via terminal:
  ```bash
  mix help typesense.import
  ```

  ## Examples

  ```bash
  # creates a collection from Person module
  mix typesense.import App.Accounts.Person
  ```

  """

  @impl Mix.Task
  @spec run([String.t()]) :: IO.puts()
  def run(_args) do
    IO.puts("TODO: import")
  end
end
