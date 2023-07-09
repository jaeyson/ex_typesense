defmodule SearchTest do
  use ExUnit.Case, async: false
  import Ecto.Query, warn: false
  alias ExTypesense.TestSchema.Person
  # doctest ExTypesense.Search

  setup_all do
    [{:api_key, "xyz"}, {:host, "localhost"}, {:port, 8108}, {:scheme, "http"}]
    |> Enum.each(fn {key, val} -> Application.put_env(:ex_typesense, key, val) end)

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

    ExTypesense.create_collection(schema)
    ExTypesense.create_collection(Person)

    {:ok, _} = ExTypesense.create_document(document)
    {:ok, _} = ExTypesense.create_document(person)

    on_exit(fn ->
      ExTypesense.drop_collection(schema.name)
      ExTypesense.drop_collection(Person)

      [:api_key, :host, :port, :scheme]
      |> Enum.each(&Application.delete_env(:ex_typesense, &1))
    end)

    %{schema: schema, document: document, person: person}
  end

  test "success: search with result", %{schema: schema} do
    params = %{
      q: "test",
      query_by: "company_name"
    }

    assert {:ok, _} = ExTypesense.search(schema.name, params)
  end

  test "success: search with Ecto", %{person: person} do
    params = %{
      q: "UK",
      query_by: "country"
    }

    assert %Ecto.Query{} = Person |> where([p], p.id in ^[person.person_id])
    assert %Ecto.Query{} = ExTypesense.search(Person, params)
  end

  test "success: empty result", %{schema: schema} do
    params = %{
      q: "unknown",
      query_by: "company_name"
    }

    assert {:ok, _} = ExTypesense.search(schema.name, params)
  end
end
