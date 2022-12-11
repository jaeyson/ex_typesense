# ExTypesense

Typesense client for Elixir with support for importing your Ecto schemas.

## TODO:

- [ ] import ecto schemas to propagate collections/documents.
- [ ] creating collection using auto schema detection.
- [ ] implement search/geosearch/multisearch.
- [ ] implement curation.
- [ ] implement synonyms.

## local typesense server

```bash
docker container run --rm -it -d --name typesense -e TYPESENSE_DATA_DIR=/data -e TYPESENSE_API_KEY=xyz -v /tmp/typesense-server-data:/data -p 8108:8108 typesense/typesense:0.23.1
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_typesense` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_typesense, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ex_typesense>.
