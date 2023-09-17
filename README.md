# ExTypesense

[![Hex.pm](https://img.shields.io/hexpm/v/ex_typesense)](https://hex.pm/packages/ex_typesense)
[![Hexdocs.pm](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/ex_typesense)
[![Hex.pm](https://img.shields.io/hexpm/l/ex_typesense)](LICENSE)
[![Typesense badge](https://img.shields.io/badge/Typesense-v0.25.1-darkblue)](https://typesense.org/docs/0.25.1/api)

Typesense client for Elixir with support for your Ecto schemas.

## Todo

- creating collection using auto schema detection
- implement multisearch
- implement geosearch
- implement curation
- implement synonyms

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_typesense` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_typesense, "~> 0.3"}
  ]
end
```

If you're adding this dep as a local path:

```elixir
def deps do
  [
    {:ex_typesense, path: "/path/to/ex_typesense"}
  ]
end
```

then

```bash
mix deps.compile ex_typesense --force
```

## Getting started

### 1. Spin up local typesense server

```bash
mkdir /tmp/typesense-server-data
```

```bash
docker container run --rm -it -d \
  --name typesense \
  -e TYPESENSE_DATA_DIR=/data \
  -e TYPESENSE_API_KEY=xyz \
  -v /tmp/typesense-server-data:/data \
  -p 8108:8108 \
  docker.io/typesense/typesense:0.25.1
```

### 2. Add creds to config

Config for setting up api key, host, etc.

> You can also find api key and host in your dashboard if you're using [cloud-hosted](https://cloud.typesense.org) Typesense.

```elixir
config :ex_typesense,
  api_key: "xyz",
  host: "localhost", # "111222333aaabbbcc-9.x9.typesense.net"
  port: 8108, # 443
  scheme: "http" # "https"
  ```

### 3. Create a collection

#### using Ecto

In this example, we're adding `person_id` that points to the id of `persons` schema.

```elixir
defmodule Person do
  use Ecto.Schema

  defimpl Jason.Encoder, for: __MODULE__ do
    def encode(value, opts) do
      value
      |> Map.take([:id, :person_id, :name, :country])
      |> Enum.map(fn {key, val} ->
        cond do
          key === :id -> {key, to_string(Map.get(value, :id))}
          key === :person_id -> {key, Map.get(value, :id)}
          true -> {key, val}
        end
      end)
      |> Enum.into(%{})
      |> Jason.Encode.map(opts)
    end
  end

  schema "persons" do
    field(:name, :string)
    field(:country, :string)
    field(:person_id, :integer, virtual: true)
  end

  def get_field_types do
    %{
      default_sorting_field: "person_id",
      fields: [
        %{name: "person_id", type: "int32"},
        %{name: "name", type: "string"},
        %{name: "country", type: "string"}
      ]
    }
  end
end
```

next, create the collection from a module name

```elixir
ExTypesense.create_collection(Person)
```

#### using maps

```elixir
schema = %{
  name: "companies",
  fields: [
    %{name: "company_name", type: "string"},
    %{name: "company_id", type: "int32"},
    %{name: "country", type: "string"}
  ],
  default_sorting_field: "company_id"
}

ExTypesense.create_collection(schema)
```

### 4. Indexing documents

#### 4.a via indexing multiple documents

```elixir
Post |> Repo.all() |> ExTypesense.index_multiple_documents()
```

#### 4.b or indexing single document

```elixir
Post |> Repo.get!(123) |> ExTypesense.create_document()
```

### 5. Search

```elixir
params = %{q: "John Doe", query_by: "name"}

ExTypesense.search(schema.name, params)
ExTypesense.search(Person, params)
```

Check [cheatsheet](https://hexdocs.pm/ex_typesense/cheatsheet.html) for more examples

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ex_typesense>.
