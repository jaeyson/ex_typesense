defmodule DocumentTest do
  use ExUnit.Case, async: false

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

    multiple_documents = %{
      collection_name: "companies",
      documents: [
        %{
          company_name: "Industrial Mills, Co.",
          company_id: 990,
          country: "US"
        },
        %{
          company_name: "Washing Machine, Inc.",
          company_id: 10,
          country: "US"
        }
      ]
    }

    ExTypesense.create_collection(schema)

    on_exit(fn ->
      ExTypesense.drop_collection(schema.name)
      # from doctest
      ExTypesense.drop_collection("posts")

      [:api_key, :host, :port, :scheme]
      |> Enum.each(&Application.delete_env(:ex_typesense, &1))
    end)

    %{schema: schema, document: document, multiple_documents: multiple_documents}
  end

  test "error: get unknown document", %{schema: schema} do
    unknown_id = 999
    message = ~s(Could not find a document with id: #{unknown_id})
    assert {:error, message} === ExTypesense.get_document(schema.name, unknown_id)
  end

  test "success: index a document using a map then fetch if indexed", %{document: document} do
    {:ok, %{"id" => id, "company_name" => company_name}} = ExTypesense.create_document(document)
    id = String.to_integer(id)
    {:ok, result} = ExTypesense.get_document("companies", id)
    assert result["company_name"] === company_name
  end

  test "success: adding unknown field", %{document: document} do
    document = Map.put(document, :unknown_field, "unknown_value")
    {:ok, collection} = ExTypesense.create_document(document)
    assert Map.has_key?(collection, "unknown_field")
  end

  test "success: upsert to update a document", %{document: document} do
    {:ok, %{"id" => id}} = ExTypesense.create_document(document)
    id = String.to_integer(id)
    company_name = "Stark Industries"

    updated_document =
      document
      |> Map.put(:company_name, company_name)
      |> Map.put(:id, id)

    {:ok, result} = ExTypesense.upsert_document(updated_document)

    assert company_name === result["company_name"]
  end

  test "success: create document using upsert_document/2", %{document: document} do
    document = Map.put(document, :id, "9999")
    assert {:ok, %{"id" => "9999"}} = ExTypesense.upsert_document(document)
  end

  test "error: creates a document with a specific id twice", %{document: document} do
    document = Map.put(document, :id, "99")
    assert {:ok, %{"id" => id}} = ExTypesense.create_document(document)
    assert {:ok, message} = ExTypesense.create_document(document)
    assert message === %{"message" => "A document with id #{id} already exists."}
  end

  test "success: update a document", %{document: document} do
    {:ok, %{"id" => id}} = ExTypesense.create_document(document)
    company_name = "Stark Industries"

    updated_document =
      document
      |> Map.put(:company_name, company_name)
      |> Map.put(:id, id)

    {:ok, result} = ExTypesense.update_document(updated_document)

    assert company_name === result["company_name"]
  end

  test "success: deletes a document using map", %{document: document} do
    {:ok, %{"id" => id}} = ExTypesense.create_document(document)

    ExTypesense.delete_document(document.collection_name, String.to_integer(id))
  end

  test "success: index multiple documents", %{multiple_documents: multiple_documents} do
    multiple_documents
    |> ExTypesense.index_multiple_documents()
    |> Kernel.===({:ok, [%{"success" => true}, %{"success" => true}]})
    |> assert()
  end

  test "success: update multiple documents", %{
    multiple_documents: multiple_documents,
    schema: schema
  } do
    first = Enum.at(multiple_documents.documents, 0) |> Map.put(:collection_name, schema.name)
    second = Enum.at(multiple_documents.documents, 1) |> Map.put(:collection_name, schema.name)
    first_update = "first_update"
    second_update = "second_update"

    {:ok, %{"id" => first_id}} = ExTypesense.create_document(first)
    {:ok, %{"id" => second_id}} = ExTypesense.create_document(second)

    update_1 =
      first
      |> Map.put(:id, first_id)
      |> Map.put(:company_name, first_update)

    update_2 =
      second
      |> Map.put(:id, second_id)
      |> Map.put(:company_name, second_update)

    multiple_documents
    |> Map.put(:documents, [update_1, update_2])
    |> ExTypesense.update_multiple_documents()
    |> Kernel.===({:ok, [%{"success" => true}, %{"success" => true}]})
    |> assert()

    {:ok, first} = ExTypesense.get_document(schema.name, String.to_integer(first_id))
    {:ok, second} = ExTypesense.get_document(schema.name, String.to_integer(second_id))

    assert first["company_name"] === first_update
    assert second["company_name"] === second_update
  end

  test "success: upsert multiple documents", %{multiple_documents: multiple_documents} do
    multiple_documents
    |> ExTypesense.upsert_multiple_documents()
    |> Kernel.===({:ok, [%{"success" => true}, %{"success" => true}]})
    |> assert()
  end
end
