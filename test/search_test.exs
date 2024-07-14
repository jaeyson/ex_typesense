defmodule SearchTest do
  use ExUnit.Case, async: true
  import Ecto.Query, warn: false

  alias ExTypesense.TestSchema.Catalog
  alias ExTypesense.TestSchema.MultiSearch

  @embedding MultiSearch.vector_embeddings()

  setup_all do
    schema = %{
      name: "search_companies",
      fields: [
        %{name: "company_name", type: "string"},
        %{name: "company_description_embedding", type: "float[]", num_dim: 1536},
        %{name: "search_companies_id", type: "int32"},
        %{name: "country", type: "string"}
      ],
      default_sorting_field: "search_companies_id"
    }

    document = %{
      collection_name: "search_companies",
      company_name: "Test",
      company_description_embedding: @embedding,
      search_companies_id: 1001,
      country: "US"
    }

    catalog = %Catalog{
      id: 1002,
      name: "Rubber Ducky",
      description: "A tool by articulating a problem in spoken or written natural language.",
      catalogs_id: 1002
    }

    with %ExTypesense.Collection{} <- ExTypesense.create_collection(schema) do
      {:ok, _} = ExTypesense.create_document(document)
    end

    with %ExTypesense.Collection{} <- ExTypesense.create_collection(Catalog) do
      {:ok, _} = ExTypesense.create_document(catalog)
    end

    on_exit(fn ->
      ExTypesense.drop_collection(schema.name)
      ExTypesense.drop_collection(Catalog)
    end)

    %{schema: schema, document: document, catalog: catalog}
  end

  test "success: search with result", %{schema: schema} do
    params = %{
      q: "test",
      query_by: "company_name"
    }

    assert {:ok, _} = ExTypesense.search(schema.name, params)
  end

  test "success: search with Ecto", %{catalog: catalog} do
    params = %{
      q: "duck",
      query_by: "name"
    }

    assert %Ecto.Query{} = Catalog |> where([p], p.id in ^[catalog.catalogs_id])
    assert %Ecto.Query{} = ExTypesense.search(Catalog, params)
  end

  test "success: empty result", %{schema: schema} do
    params = %{
      q: "unknown",
      query_by: "company_name"
    }

    assert {:ok, %{"found" => 0, "hits" => []}} = ExTypesense.search(schema.name, params)
  end

  test "success: multi_search Ecto" do
    searches = [
      %{collection: Catalog, q: "duck", query_by: "name"},
      %{collection: "catalogs", q: "umbrella", query_by: "name"}
    ]

    assert [%Ecto.Query{}, %Ecto.Query{}] = ExTypesense.multi_search_ecto(searches)
  end

  test "success: multi_search string or module collection name" do
    searches = [%{collection: Catalog, q: "duck", query_by: "name"}]

    assert {:ok, %{"results" => [%{"found" => 1}]}} = ExTypesense.multi_search(searches)
  end

  test "success: multi_search (vector) with result", %{schema: schema} do
    searches = [
      %{
        collection: schema.name,
        q: "*",
        vector_query:
          "company_description_embedding:([#{@embedding |> Enum.map_join(", ", &Float.to_string/1)}], k:100)",
        exclude_fields: "company_description_embedding"
      }
    ]

    assert {:ok, %{"results" => results}} = ExTypesense.multi_search(searches)
    assert [%{"found" => 1, "hits" => hits} | _rest] = results

    assert [
             %{"document" => %{"company_name" => "Test"}, "vector_distance" => _some_number}
             | _rest
           ] = hits
  end

  test "error: multi_search with vector_search by an id that doesn't exist", %{schema: schema} do
    searches = [
      %{
        collection: schema.name,
        q: "*",
        vector_query: "company_description_embedding:([], id: 1)",
        exclude_fields: "company_description_embedding"
      }
    ]

    # Errors are returned per-search and must be extracted separately
    reason = "Document id referenced in vector query is not found."
    assert {:ok, %{"results" => [%{"error" => ^reason} | _]}} = ExTypesense.multi_search(searches)
  end
end
