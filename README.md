<p align="center">
  <img
    alt="Typesense logo"
    src="https://github.com/typesense/typesense/raw/main/assets/typesense_logo.svg"
    width="298">
  <img
    alt="lightning bolt svg"
    src="https://github.com/jaeyson/ex_typesense/raw/main/assets/lightning-bolt.svg"
    width="200">
  <source
    media="(prefers-color-scheme: dark)"
    srcset="https://github.com/elixir-lang/elixir-lang.github.com/raw/main/images/logo/logo-dark.png">
  <img
    alt="Elixir logo"
    src="https://github.com/elixir-lang/elixir-lang.github.com/raw/main/images/logo/logo.png"
    width="200">
</p>

<h1 align="center">ExTypesense</h1>

<p align="center">
  <a href="https://hex.pm/packages/ex_typesense">
    <img
      alt="ex_typesense latest version badge"
      src="https://img.shields.io/hexpm/v/ex_typesense"
    >
  </a>
  <a href="https://hexdocs.pm/ex_typesense">
    <img
      alt="ex_typesense hexdocs badge"
      src="https://img.shields.io/badge/hex-docs-lightgreen.svg"
    >
  </a>
  <a href="https://github.com/jaeyson/ex_typesense/actions/workflows/ci.yml">
    <img
      alt="Github actions workflow badge"
      src="https://github.com/jaeyson/ex_typesense/actions/workflows/ci.yml/badge.svg"
    >
  </a>
  <a href="https://hexdocs.pm/ex_typesense/license.html">
    <img
      alt="ex_typesense license badge"
      src="https://img.shields.io/hexpm/l/ex_typesense"
    >
  </a>
  <a href="https://typesense.org/docs/27.1/api">
    <img
      alt="Latest Typesense version compatible badge"
      src="https://img.shields.io/badge/Typesense-v27.1-darkblue"
    >
  </a>
  <a href="https://coveralls.io/github/jaeyson/ex_typesense?branch=main">
    <img
      alt="Test coverage badge"
      src="https://coveralls.io/repos/github/jaeyson/ex_typesense/badge.svg?branch=main"
    >
  </a>
</p>

[Typesense](https://typesense.org) client for [Elixir](https://elixir-lang.org) with support for your Ecto schemas.

> #### OpenAPI adherence {: .tip}
>
> Under the hood, this library utilizes [open_api_typesense](https://github.com/jaeyson/open_api_typesense)
> to make sure it adheres to [Typesense's OpenAPI spec](https://github.com/typesense/typesense-api-spec).

> #### upgrading to `1.0.0` contains **LOTS** of breaking changes. {: .warning}

## Installation

ExTypesense requires Elixir `~> 1.14.x`. Read the [Changelog](CHANGELOG.md) for all available
releases and requirements. This library is published to both [Hex.pm](https://hex.pm/ex_typesense)
and [GitHub ](https://github.com/jaeyson/ex_typesense.git) repository.

Add `:ex_typesense` to your list of dependencies in the Elixir project config file, `mix.exs`:

```elixir
def deps do
  [
    # From default Hex package manager
    {:ex_typesense, "~> 1.0"}

    # Or from GitHub repository, if you want the latest greatest from main branch
    {:ex_typesense, git: "https://github.com/jaeyson/ex_typesense.git"}
  ]
end
```

## Getting started

### 0. (Optional) Run local Typesense instance

If you want to try this library locally:

```bash
docker compose up -d
```

More info on spinning a local instance: https://typesense.org/docs/guide/install-typesense.html

Otherwise, go to step #1 if you're using [Cloud hosted](https://cloud.typesense.org) instance instead.

### 1. Add credential to config

After you have setup a [local](./guides/running_local_typesense.md) Typesense or
[Cloud hosted](https://cloud.typesense.org) instance, there are 2 ways to set the credentials:

<!-- tabs-open -->

### using config

Option 1: Set credentials via config (e.g. `config/runtime.exs`)

```elixir
# e.g. config/runtime.exs
if config_env() == :prod do # if you'll use this in prod environment
  config :open_api_typesense,
    api_key: "xyz",
    host: "localhost",
    port: 8108,
    scheme: "http"
  ...
```

> #### `options` key {: .tip}
>
> The `options` key can be used to pass additional configuration
> options such as custom Finch instance or receive timeout
> settings. You can add any options supported by Req here. For
> more details check [Req documentation](https://hexdocs.pm/req/Req.Steps.html#run_finch/1-request-options).

> #### during tests {: .tip}
>
> If you have a different config for your app, consider 
> adding it in `config/test.exs`.

For Cloud hosted, you can generate and obtain the credentials from cluster instance admin interface:

```elixir
config :open_api_typesense,
  api_key: "credential", # Admin API key
  host: "111222333aaabbbcc-9.x9.typesense.net", # Nodes
  port: 443,
  scheme: "https"
```

### using map

Option 2: Set credentials from a map

> #### optional `conn` {: .tip}
>
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

As long as the keys matches in [`OpenApiTypesense.Connection.t()`](https://hexdocs.pm/open_api_typesense/OpenApiTypesense.Connection.html#t:t/0):

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

Or convert your struct to map, as long as the keys matches in [`OpenApiTypesense.Connection.t()`](https://hexdocs.pm/open_api_typesense/OpenApiTypesense.Connection.html#t:t/0):

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

Or just plain map

```elixir
conn = %{
    host: "127.0.0.1",
    api_key: "xyz",
    port: 8108,
    scheme: "http"
}

ExTypesense.health(conn)
```

<!-- tabs-close -->

### 2. Create a collection

There are 2 ways to create a collection, either via
[Ecto schema](https://hexdocs.pm/ecto/Ecto.Schema.html) or using map
([an Elixir data type](https://hexdocs.pm/elixir/keywords-and-maps.html#maps-as-key-value-pairs)):

<!-- tabs-open -->

### using Ecto schema

> #### added fk in schema {: .info}
>
> The format we're using is `<TABLE_NAME>_id`. If you have table e.g. named `persons`,
> it'll be `persons_id`.
>
> `persons_id` is of type `integer`: read the discussion on why
> we need to add [default_sorting_field](https://github.com/typesense/typesense/issues/72#issuecomment-645725013).

```elixir
defmodule Person do
  use Ecto.Schema
  @behaviour ExTypesense

  # In this example, we're adding `persons_id`
  # that points to the id of `persons` schema.

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
      name = __MODULE__.__schema__(:source)
      primary_field = name <> "_id"

    %{
      name: name,
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

### using map

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

<!-- tabs-close -->

### 3. Indexing documents

<!-- tabs-open -->

### single document

```elixir
Post |> Repo.get!(123) |> ExTypesense.index_document()
```

### multiple document

```elixir
Post |> Repo.all() |> ExTypesense.import_documents()
```

<!-- tabs-close -->

### 4. Search

```elixir
params = %{q: "John Doe", query_by: "name"}

ExTypesense.search(schema.name, params)
ExTypesense.search(Person, params)
```

Check [Cheatsheet](https://hexdocs.pm/ex_typesense/cheatsheet.html) for more usage examples.

## Miscellaneous

## Adding [cache, retry, compress_body](https://hexdocs.pm/req/Req.html#new/1) in the built in client

E.g. when a user wants to change `retry` and `cache` options

```elixir
ExTypesense.get_collection("companies", req: [retry: false, cache: true])
```

See implementation: https://github.com/jaeyson/open_api_typesense/blob/main/lib/open_api_typesense/client.ex#L82

### Use non-default Finch adapter

For instance, in a scenario where an application has multiple Finch pools configured for
different services, a developer might want to specify a particular Finch pool for the
`HttpClient` to use. This can be achieved by configuring the options as follows:

```elixir
config :open_api_typesense,
  api_key: "XXXXXX",
  #...
  options: [finch: MyApp.CustomFinch] # <- add options
```

In this example, `MyApp.CustomFinch` is a custom Finch pool that the developer has
configured with specific connection options or other settings that differ from the
default Finch pool.

## Using another client

By default this library is using [Req](https://hexdocs.pm/req/readme.html). In order to use another HTTP client,
OpenApiTypesense has a callback function ([Behaviours](https://hexdocs.pm/elixir/typespecs.html#behaviours))
called `request` that contains 2 args:

1. `conn`: your connection map
2. `params`: payload, header, and client-related stuffs.

> #### `conn` and `params` {: .info}
>
> you can change the name `conn` and/or `params` however you want,
> since it's just a variable.

Here's a custom client example ([HTTPoison](https://hexdocs.pm/httpoison/readme.html)) in order to match the usage:

<!-- tabs-open -->

### Client module

```elixir
defmodule MyApp.CustomClient do
  @behaviour OpenApiTypesense.Client
  
  @impl OpenApiTypesense.Client
  def request(conn, params) do
    url = %URI{
      scheme: conn.scheme,
      host: conn.host,
      port: conn.port,
      path: params.url,
      query: URI.encode_query(params[:query] || %{})
    }
    |> URI.to_string()

    request = %HTTPoison.Request{method: params.method, url: url}

    request =
      if params[:request] do
        [{content_type, _schema}] = params.request

        headers = [
          {"X-TYPESENSE-API-KEY", conn.api_key}
          {"Content-Type", content_type}
        ]

        %{request | headers: headers}
      else
        request
      end

    request =
      if params[:body] do
        %{request | body: Jason.encode!(params.body)}
      else
        request
      end

    HTTPoison.request!(request)
  end
end
```

### Client config

```elixir
config :open_api_typesense,
  api_key: "xyz", # Admin API key
  host: "localhost", # Nodes
  port: 8108,
  scheme: "http",
  client: MyApp.CustomClient # <- add this
```

<!-- tabs-close -->

Visit `open_api_typesense` docs for further [examples](https://hexdocs.pm/open_api_typesense/custom_http_client.html)

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
