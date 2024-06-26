# ExTypesense

[![Hex.pm](https://img.shields.io/hexpm/v/ex_typesense)](https://hex.pm/packages/ex_typesense)
[![Hexdocs.pm](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/ex_typesense)
[![Hex.pm](https://img.shields.io/hexpm/l/ex_typesense)](https://hexdocs.pm/ex_typesense/license.html)
[![Typesense badge](https://img.shields.io/badge/Typesense-v26.0-darkblue)](https://typesense.org/docs/26.0/api)
[![Coverage Status](https://coveralls.io/repos/github/jaeyson/ex_typesense/badge.svg?branch=main)](https://coveralls.io/github/jaeyson/ex_typesense?branch=main)

Typesense client for Elixir with support for your Ecto schemas.

**Note**: Breaking changes if you're upgrading from `0.3.x` to upcoming `0.5.x` version.

## Todo

- creating collection using auto schema detection
- implement multisearch
- implement geosearch
- implement curation
- implement synonyms

## Installation

ExTypesense requires Elixir `~> 1.14.x`. Read the [Changelog](CHANGELOG.md) for all available releases and requirements. This library is published to both [Hex.pm](https://hex.pm/ex_typesense) and [GitHub ](https://github.com/jaeyson/ex_typesense.git) repository.

Add `:ex_typesense` to your list of dependencies in the Elixir project config file, `mix.exs`:

```elixir
def deps do
  [
    # From default Hex package manager
    {:ex_typesense, "~> 0.4"}

    # Or from GitHub repository, if you want to latest greatest from main branch
    {:ex_typesense, git: "https://github.com/jaeyson/ex_typesense.git"}
  ]
end
```

## Getting started

### 0. Run local Typesense instance

```bash
docker compose up -d
```

More info on spinning a local instance: https://typesense.org/docs/guide/install-typesense.html

### 1. Add credential to config

After you have setup a [local](./guides/running_local_typesense.md) Typesense or [Cloud hosted](https://cloud.typesense.org) instance, there are 2 ways to set the credentials:

#### Option 1: Set credentials via config (e.g. `config/runtime.exs`)

You can set the following config details to the config file:

```elixir
config :ex_typesense,
  api_key: "xyz",
  host: "localhost",
  port: 8108,
  scheme: "http"
```

For Cloud hosted, you can generate and obtain the credentials from cluster instance admin interface:

```elixir
config :ex_typesense,
  api_key: "credential", # Admin API key
  host: "111222333aaabbbcc-9.x9.typesense.net" # Nodes
  port: 443,
  scheme: "https"
```

#### Option 2: Dynamic connection using an Ecto schema

> By default you don't need to pass connections every
> time you use a function, if you use "Option 1" above.

You may have a `Connection` Ecto schema in your app and want to pass your own creds dynamically.

```elixir
defmodule MyApp.Credential do
  schema "credentials" do
    field :node, :string
    field :secret_key, :string
    field :port, :integer
  end
end
```

using Connection struct

```elixir
credential = MyApp.Credential |> where(id: ^8888) |> Repo.one()

conn = %ExTypesense.Connection{
  host: credential.node,
  api_key: credential.secret_key,
  port: credential.port,
  scheme: "https"
}

ExTypesense.search(conn, collection_name, query)
```

or maps, as long as the keys matches in `ExTypesense.Connection.t()`

```elixir
conn = %{
  host: credential.node,
  api_key: credential.secret_key,
  port: credential.port,
  scheme: "https"
}

ExTypesense.search(conn, collection_name, query)

```

or convert your struct to map, as long as the keys matches in `ExTypesense.Connection.t()`

```elixir
conn = Map.from_struct(MyApp.Credential)

ExTypesense.search(conn, collection_name, query)

```

or you don't want to change the fields in your schema, thus you convert it to map

```elixir
conn = %Credential{
  node: "localhost",
  secret_key: "xyz",
  port: 8108,
  scheme: "http"
}

conn =
  conn
  |> Map.from_struct()
  |> Map.drop([:node, :secret_key])
  |> Map.put(:host, conn.node)
  |> Map.put(:api_key, conn.secret_key)

ExTypesense.search(conn, collection_name, query)
```

### 2. Create a collection

There are 2 ways to create a collection, either via [Ecto schema](https://hexdocs.pm/ecto/Ecto.Schema.html) or using map ([an Elixir data type](https://hexdocs.pm/elixir/keywords-and-maps.html#maps-as-key-value-pairs)):

#### Option 1: using Ecto

In this example, we're adding `person_id` that points to the id of `persons` schema.

```elixir
defmodule Person do
  use Ecto.Schema
  @behaviour ExTypesense

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

  @impl ExTypesense
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

Next, create the collection from a module name.

```elixir
ExTypesense.create_collection(Person)
```

#### Option 2: using map

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

### 3. Indexing documents

For multiple documents:

```elixir
Post |> Repo.all() |> ExTypesense.index_multiple_documents()
```

For single document:

```elixir
Post |> Repo.get!(123) |> ExTypesense.create_document()
```

### 4. Search

```elixir
params = %{q: "John Doe", query_by: "name"}

ExTypesense.search(schema.name, params)
ExTypesense.search(Person, params)
```

Check [Cheatsheet](https://hexdocs.pm/ex_typesense/cheatsheet.html) for more usage examples.

## License

Copyright (c) 2021 Jaeyson Anthony Y.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
