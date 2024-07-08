defmodule DocumentTest do
  use ExUnit.Case, async: true

  alias ExTypesense.TestSchema.Person

  setup_all do
    schema = %{
      name: "doc_companies",
      fields: [
        %{name: "company_name", type: "string"},
        %{name: "doc_companies_id", type: "int32"},
        %{name: "country", type: "string"}
      ],
      default_sorting_field: "doc_companies_id"
    }

    document = %{
      collection_name: "doc_companies",
      company_name: "Test",
      doc_companies_id: 1001,
      country: "US"
    }

    multiple_documents = %{
      collection_name: "doc_companies",
      documents: [
        %{
          company_name: "Industrial Mills, Co.",
          doc_companies_id: 990,
          country: "US"
        },
        %{
          company_name: "Washing Machine, Inc.",
          doc_companies_id: 10,
          country: "US"
        }
      ]
    }

    ExTypesense.create_collection(schema)
    ExTypesense.create_collection(Person)

    on_exit(fn ->
      ExTypesense.drop_collection(schema.name)
      ExTypesense.drop_collection(Person)
    end)

    %{schema: schema, document: document, multiple_documents: multiple_documents}
  end

  test "error: get unknown document", %{schema: schema} do
    unknown_id = 999
    message = ~s(Could not find a document with id: #{unknown_id})
    assert {:error, message} === ExTypesense.get_document(schema.name, unknown_id)
  end

  test "success: index a document using a map then fetch if indexed", %{document: document} do
    {:ok, %{"id" => id, "company_name" => company_name}} =
      ExTypesense.create_document(document)

    id = String.to_integer(id)
    {:ok, result} = ExTypesense.get_document("doc_companies", id)
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
    assert {:error, message} = ExTypesense.create_document(document)
    assert message === "A document with id #{id} already exists."
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

    assert {:ok, _} =
             ExTypesense.delete_document({document.collection_name, String.to_integer(id)})
  end

  test "success: deletes a document by struct" do
    person = %Person{id: 99, name: "John Smith", persons_id: 99, country: "Brazil"}

    assert {:ok,
            %{"country" => "Brazil", "id" => _, "name" => "John Smith", "persons_id" => 99}} =
             ExTypesense.create_document(person)

    assert {:ok, _} = ExTypesense.delete_document(person)
  end

  test "success: deletes a document by id", %{document: document} do
    {:ok, %{"id" => id}} = ExTypesense.create_document(document)

    assert {:ok, _} =
             ExTypesense.delete_document({document.collection_name, String.to_integer(id)})
  end

  test "success: index multiple documents", %{multiple_documents: multiple_documents} do
    assert {:ok, [%{"success" => true}, %{"success" => true}]} ===
             ExTypesense.index_multiple_documents(multiple_documents)
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

    multiple_documents = Map.put(multiple_documents, :documents, [update_1, update_2])

    assert {:ok, [%{"success" => true}, %{"success" => true}]} ===
             ExTypesense.update_multiple_documents(multiple_documents)

    {:ok, first} = ExTypesense.get_document(schema.name, String.to_integer(first_id))
    {:ok, second} = ExTypesense.get_document(schema.name, String.to_integer(second_id))

    assert first["company_name"] === first_update
    assert second["company_name"] === second_update
  end

  test "success: upsert multiple documents", %{multiple_documents: multiple_documents} do
    assert {:ok, [%{"success" => true}, %{"success" => true}]} ===
             ExTypesense.upsert_multiple_documents(multiple_documents)
  end

  test "error: upsert multiple documents with struct type" do
    persons = [
      %Person{id: 1, name: "John Smith"},
      %Person{id: 2, name: "Jane Smith"}
    ]

    assert {:error, ~s(It should be type of map, ":documents" key should contain list of maps)} ===
             ExTypesense.upsert_multiple_documents(persons)
  end

  test "success: delete all documents using Ecto schema module" do
    person = %Person{id: 1, name: "John Doe", persons_id: 1, country: "Scotland"}

    assert {:ok, %{"country" => "Scotland", "id" => _, "name" => "John Doe", "persons_id" => 1}} =
             ExTypesense.create_document(person)

    assert {:ok, %{"num_deleted" => 1}} == ExTypesense.delete_all_documents(Person)
  end

  test "success: delete all documents in a collection" do
    multiple_documents = %{
      collection_name: "doc_companies",
      documents: [
        %{
          company_name: "Boca Cola",
          doc_companies_id: 227,
          country: "SG"
        },
        %{
          company_name: "Motor, Inc.",
          doc_companies_id: 99,
          country: "TH"
        }
      ]
    }

    assert {:ok, [%{"success" => true}, %{"success" => true}]} ===
             ExTypesense.index_multiple_documents(multiple_documents)

    {:ok, %{"num_deleted" => documents_deleted}} =
      ExTypesense.delete_all_documents(multiple_documents.collection_name)

    assert documents_deleted > 0
  end

  test "success: delete documents by query" do
    assert nil === true
  end
end
