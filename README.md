# ExTypesense

[![Hex.pm](https://img.shields.io/hexpm/v/ex_typesense)](https://hex.pm/packages/ex_typesense)
[![Hexdocs.pm](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/ex_typesense)
[![Actions Status](https://github.com/jaeyson/ex_typesense/actions/workflows/ci.yml/badge.svg)](https://github.com/jaeyson/ex_typesense/actions)
[![Hex.pm](https://img.shields.io/hexpm/l/ex_typesense)](https://hexdocs.pm/ex_typesense/license.html)
[![Typesense badge](https://img.shields.io/badge/Typesense-v26.0-darkblue)](https://typesense.org/docs/26.0/api)
[![Coverage Status](https://coveralls.io/repos/github/jaeyson/ex_typesense/badge.svg?branch=main)](https://coveralls.io/github/jaeyson/ex_typesense?branch=main)

Typesense client for Elixir with support for your Ecto schemas.

> **Note**: Breaking changes if you're upgrading from `0.3.x` to `0.5.x` version and above.

## Todo

- creating collection using auto schema detection
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
    {:ex_typesense, "~> 0.7"}

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
if config_env() == :prod do # if you'll use this in prod environment
  config :ex_typesense,
    api_key: "xyz",
    host: "localhost",
    port: 8108,
    scheme: "http",
    options: %{}
  ...
```

> **Note**: The `options` key can be used to pass additional configuration options such as custom Finch instance or receive timeout settings. You can add any options supported by Req here. For more details check [Req documentation](https://hexdocs.pm/req/Req.Steps.html#run_finch/1-request-options).

> **Note**: If you use this for adding test in your app, you might want to add this in `config/test.exs`:

For Cloud hosted, you can generate and obtain the credentials from cluster instance admin interface:

```elixir
config :ex_typesense,
  api_key: "credential", # Admin API key
  host: "111222333aaabbbcc-9.x9.typesense.net" # Nodes
  port: 443,
  scheme: "https",
  options: %{}
```

#### Option 2: Set credentials from a map

> By default you don't need to pass connections every
> time you use a function, if you use "Option 1" above.

You may have a `Connection` Ecto schema in your app and want to pass your own creds dynamically:

```elixir
defmodule MyApp.Credential do
  schema "credentials" do
    field :node, :string
    field :secret_key, :string
    field :port, :integer
  end
end
```

As long as the keys matches in `ExTypesense.Connection.t()`:

```elixir
credential = MyApp.Credential |> where(id: ^8888) |> Repo.one()

conn = %{
  host: credential.node,
  api_key: credential.secret_key,
  port: credential.port,
  scheme: "https"
}

# NOTE: create a collection and import documents
# first before using the command below
ExTypesense.search(conn, collection_name, query)
```

Or convert your struct to map, as long as the keys matches in `ExTypesense.Connection.t()`:

```elixir
conn = Map.from_struct(MyApp.Credential)

# NOTE: create a collection and import documents
# first before using the command below
ExTypesense.search(conn, collection_name, query)
```

Or you don't want to change the fields in your Ecto schema, thus you convert it to map:

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

# NOTE: create a collection and import documents
# first before using the command below
ExTypesense.search(conn, collection_name, query)
```

### 2. Create a collection

There are 2 ways to create a collection, either via [Ecto schema](https://hexdocs.pm/ecto/Ecto.Schema.html) or using map ([an Elixir data type](https://hexdocs.pm/elixir/keywords-and-maps.html#maps-as-key-value-pairs)):

#### Option 1: using Ecto

In this example, we're adding `persons_id` that points to the id of `persons` schema.

> **Note**: we're using `<TABLE_NAME>_id`. If you have table
> e.g. named `persons`, it'll be `persons_id`.

```elixir
defmodule Person do
  use Ecto.Schema
  @behaviour ExTypesense

  defimpl Jason.Encoder, for: __MODULE__ do
    def encode(value, opts) do
      value
      |> Map.take([:id, :persons_id, :name, :country])
      |> Enum.map(fn {key, val} ->
        cond do
          key === :id -> {key, to_string(Map.get(value, :id))}
          key === :persons_id -> {key, Map.get(value, :id)}
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
    field(:persons_id, :integer, virtual: true)
  end

  @impl ExTypesense
  def get_field_types do
    primary_field = __MODULE__.__schema__(:source) <> "_id"

    %{
      # Or might as well just write persons_id instead. Up to you.
      default_sorting_field: primary_field,
      fields: [
        %{name: primary_field, type: "int32"},
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
    %{name: "companies_id", type: "int32"},
    %{name: "country", type: "string"}
  ],
  default_sorting_field: "companies_id"
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

## Miscellaneous

### Use non-default Finch adapter

For instance, in a scenario where an application has multiple Finch pools configured for different services, a developer might want to specify a particular Finch pool for the `HttpClient` to use. This can be achieved by configuring the options as follows:

```elixir
config :ex_typesense,
  api_key: "XXXXXX",
  #...
  options: [finch: MyApp.CustomFinch]
```

In this example, `MyApp.CustomFinch` is a custom Finch pool that the developer has configured with specific connection options or other settings that differ from the default Finch pool.

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
