defmodule ExTypesense.ResultParser do
  import Ecto.Query, warn: false

  @moduledoc false

  @doc since: "0.1.0"
  @spec hits_to_query(Enum.t(), module() | String.t()) :: Ecto.Query.t()
  def hits_to_query(hits, schema_name) when hits == [] do
    schema_name
    |> where([i], i.id in [])
  end

  def hits_to_query(hits, schema_name) when is_atom(schema_name) do
    primary_field = schema_name.__schema__(:source) <> "_id"
    do_hits_to_query(hits, schema_name, primary_field)
  end

  def hits_to_query(hits, schema_name) when is_binary(schema_name) do
    do_hits_to_query(hits, schema_name, schema_name <> "_id")
  end

  def do_hits_to_query(hits, schema_name, primary_field) do
    values =
      Enum.map(hits, fn %{"document" => document} ->
        document[primary_field]
      end)

    schema_name
    |> where([i], i.id in ^values)
  end
end
