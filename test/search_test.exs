defmodule SearchTest do
  use ExUnit.Case, async: true
  import Ecto.Query, warn: false

  alias ExTypesense.TestSchema.Catalog

  setup_all do
    schema = %{
      name: "search_companies",
      fields: [
        %{name: "company_name", type: "string"},
        %{name: "company_id", type: "int32"},
        %{name: "country", type: "string"}
      ],
      default_sorting_field: "company_id"
    }

    document = %{
      collection_name: "search_companies",
      company_name: "Test",
      company_id: 1001,
      country: "US"
    }

    catalog = %Catalog{
      id: 1002,
      name: "Rubber Ducky",
      description: "A tool by articulating a problem in spoken or written natural language.",
      catalog_id: 1002
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

    assert %Ecto.Query{} = Catalog |> where([p], p.id in ^[catalog.catalog_id])
    assert %Ecto.Query{} = ExTypesense.search(Catalog, params)
  end

  test "success: empty result", %{schema: schema} do
    params = %{
      q: "unknown",
      query_by: "company_name"
    }

    assert {:ok, %{"found" => 0, "hits" => []}} = ExTypesense.search(schema.name, params)
  end
end
