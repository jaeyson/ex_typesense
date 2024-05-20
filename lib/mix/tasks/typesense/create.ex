defmodule Mix.Tasks.Typesense.Create do
  use Mix.Task

  @moduledoc since: "0.4.0"
  @moduledoc """
  ## Usage

  `mix typesense.create [Types] [Resources ...]`

  Creates an `alias` or collection `schema`. A *Collection* is roughly equivalent
  to a table in a relational database. *Schema* is like a table (or *schema* in some
  RDBMS) in a relational database where we translate this to an Ecto schema.

  To view this via terminal:
  ```bash
  mix help typesense.create
  ```

  ## Types

  > *Note*: only 1 type can be used per mix task

  - `--schema`: Collection name
  - `--alias`: Collection alias

  ## Examples

  ### `mix typesense.create --alias FROM TO`

  - `FROM`:
  - `TO`:

  ```bash
  # where persons is the collection alias
  mix typesense.create --alias persons_dec_2023 persons

  mix typesense.create --alias App.Accounts.Person persons_alias
  ```

  ### `mix typesense.create --schema SCHEMA_NAME [ALIAS]`

  - `SCHEMA_NAME`:
  - `ALIAS` (optional):

  ```bash
  mix typesense.create --schema persons
  mix typesense.create --schema App.Accounts.Person <-- where the schema name will be persons.
  mix typesense.create --schema App.Accounts.Person persons_dec_2023 <-- where persons_dec_2023 is the custom name linked to that module.
  ```

  ### `mix typesense.import MODULE_NAME`

  ```bash
  mix typesense.import App.Accounts.Person
  ```

  """
  alias ExTypesense.Collection

  @collection_types ~w(--schema --alias)

  @impl Mix.Task
  @spec run([String.t()]) :: IO.puts()
  def run(args) do
    types = Enum.filter(args, &(&1 in @collection_types))
    # resources = args |> Kernel.--(commands) |> Kernel.--(types)

    cond do
      length(types) > 1 ->
        raise ArgumentError,
          message: """
          Multiple options passed:(#{Enum.join(types, ", ")}).
          See `mix help typesense` for a list of commands.
          """

      length(args) > 3 ->
        raise ArgumentError,
          message: """
          Multiple arguments passed.
          See `mix help typesense` for a list of commands.
          """

      true ->
        parse_args(args)
    end
  end

  defp parse_args(args) do
    # mix typesense.create --schema <MODULE_NAME>
    # mix typesense.create --schema <MODULE_NAME> <CUSTOM_COLLECTION_NAME>
    # mix typesense.create --alias <MODULE_NAME> <ALIAS>
    # mix typesense.create --alias <COLLECTION_NAME> <ALIAS>

    # parse_args/1: ["--alias"]
    type = Enum.find(args, &(&1 in @collection_types))
    args = Enum.reject(args, &(&1 in @collection_types))

    case type do
      "--schema" when length(args) === 1 ->
        # IO.inspect("Elixir.Nappy.Catalog.Image" |> String.to_existing_atom(), label: "module")
        # IO.inspect(:application.get_key(:nappy, :modules))
        # arg = ("Elixir." <> hd(args)) |> String.to_atom()
        IO.inspect(Application.load(Nappy))
        IO.inspect(ExTypesense.Collection.create_collection(hd(args)))

      # args
      # |> parse_name()
      # |> Collection.create_collection()

      "--schema" when length(args) > 1 ->
        [name, custom] = args
        nil

      "--alias" ->
        [alias_name, custom] = args
        nil
    end
  end

  defp parse_name(name, custom \\ nil) do
    nil
  end
end
