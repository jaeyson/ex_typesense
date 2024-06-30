defmodule SearchTest do
  use ExUnit.Case, async: true
  import Ecto.Query, warn: false
  alias ExTypesense.TestSchema.Person

  setup_all do
    conn = %ExTypesense.Connection{
      host: "localhost",
      api_key: "xyz",
      port: 8108,
      scheme: "http"
    }

    schema = %{
      name: "companies",
      fields: [
        %{name: "company_name", type: "string"},
        %{name: "company_id", type: "int32"},
        %{name: "country", type: "string"}
      ],
      default_sorting_field: "company_id"
    }

    document = %{
      collection_name: "companies",
      company_name: "Test",
      company_id: 1001,
      country: "US"
    }

    person = %Person{
      id: 1002,
      name: "John Smith",
      country: "UK",
      person_id: 1002
    }

    ExTypesense.create_collection(conn, schema)
    ExTypesense.create_collection(conn, Person)

    {:ok, _} = ExTypesense.create_document(conn, document)
    {:ok, _} = ExTypesense.create_document(conn, person)

    on_exit(fn ->
      ExTypesense.drop_collection(conn, schema.name)
      ExTypesense.drop_collection(conn, Person)
    end)

    %{conn: conn, schema: schema, document: document, person: person}
  end

  test "success: search with result", %{conn: conn, schema: schema} do
    params = %{
      q: "test",
      query_by: "company_name"
    }

    assert {:ok, _} = ExTypesense.search(conn, schema.name, params)
  end

  test "success: search with Ecto", %{conn: conn, person: person} do
    params = %{
      q: "UK",
      query_by: "country"
    }

    assert %Ecto.Query{} = Person |> where([p], p.id in ^[person.person_id])
    assert %Ecto.Query{} = ExTypesense.search(conn, Person, params)
  end

  test "success: empty result", %{conn: conn, schema: schema} do
    params = %{
      q: "unknown",
      query_by: "company_name"
    }

    assert {:ok, _} = ExTypesense.search(conn, schema.name, params)
  end
end
