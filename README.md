# ExTypesense

[![Hex.pm](https://img.shields.io/hexpm/v/ex_typesense)](https://hex.pm/packages/ex_typesense)
[![Hexdocs.pm](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/ex_typesense)
[![Hex.pm](https://img.shields.io/hexpm/l/ex_typesense)](LICENSE.md)
[![Typesense badge](https://img.shields.io/badge/Typesense-v0.25.2-darkblue)](https://typesense.org/docs/0.25.2/api)

Typesense client for Elixir with support for your Ecto schemas.

## Todo

- creating collection using auto schema detection
- implement multisearch
- implement geosearch
- implement curation
- implement synonyms

## Installation

ExTypesense requires Elixir `~> 1.16.x`. Read the [Changelog](CHANGELOG.md) for all available releases and requirements. This library is published to both [Hex.pm](https://hex.pm/ex_typesense) and [GitHub ](https://github.com/jaeyson/ex_typesense.git) repository.

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

### 1. Add credential to config

After you have setup a [local](./guides/running_local_typesense.md) Typesense or [Cloud hosted](https://cloud.typesense.org) instance, you can set the following config details to the config file:

For local instance:

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

---

There are 2 ways to create a collection

### 2.A Create a collection using Ecto

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

Next, create the collection from a module name.

```elixir
ExTypesense.create_collection(Person)
```

### 2.B Create a collection using maps

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

### 2.C Create a collection using mix task

```bash
mix typesense.create --schema MyApp.Products.Product
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

Check [Cheatsheet](https://hexdocs.pm/ex_typesense/cheatsheet.html) for more examples.

## Importing

There are 2 ways to import data to a collection:

> **Note**: before running the command above, make sure to update the schema of `MyApp.Products.FrozenGoods` (see guide above: ["Create a collection" using Ecto.](#2-a-create-a-collection-using-ecto)).

### Using mix task

```bash
# see "mix help typesense" for more details
mix typesense.import MyApp.Products.FrozenGoods
```

### Using `IEx` shell

```elixir
iex> alias MyApp.Products.FrozenGoods

# create a collection
iex> ExTypesense.create_collection(FrozenGoods)

# fetch all records
iex> frozen_goods = Repo.all(FrozenGoods)

# import all documents to the collection
iex> ExTypesense.index_multiple_documents(frozen_goods, :frozen_good_id, :upsert)
```

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
