defmodule DocumentTest do
  use ExUnit.Case, async: true

  alias ExTypesense.TestSchema.Person

  setup_all do
    # this is for deprecated function to set the creds
    [{:api_key, "xyz"}, {:host, "localhost"}, {:port, 8108}, {:scheme, "http"}]
    |> Enum.each(fn {key, val} -> Application.put_env(:ex_typesense, key, val) end)

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

    ExTypesense.create_collection(conn, schema)
    ExTypesense.create_collection(conn, Person)

    on_exit(fn ->
      ExTypesense.drop_collection(conn, schema.name)
      ExTypesense.drop_collection(conn, Person)
      # from doctest
      ExTypesense.drop_collection(conn, "posts")

      # this is for deprecated function to set the creds
      [:api_key, :host, :port, :scheme]
      |> Enum.each(&Application.delete_env(:ex_typesense, &1))
    end)

    %{conn: conn, schema: schema, document: document, multiple_documents: multiple_documents}
  end

  test "error: get unknown document", %{conn: conn, schema: schema} do
    unknown_id = 999
    message = ~s(Could not find a document with id: #{unknown_id})
    assert {:error, message} === ExTypesense.get_document(conn, schema.name, unknown_id)
  end

  test "success: index a document using a map then fetch if indexed", %{
    conn: conn,
    document: document
  } do
    {:ok, %{"id" => id, "company_name" => company_name}} =
      ExTypesense.create_document(conn, document)

    id = String.to_integer(id)
    {:ok, result} = ExTypesense.get_document(conn, "companies", id)
    assert result["company_name"] === company_name
  end

  test "success: adding unknown field", %{conn: conn, document: document} do
    document = Map.put(document, :unknown_field, "unknown_value")
    {:ok, collection} = ExTypesense.create_document(conn, document)
    assert Map.has_key?(collection, "unknown_field")
  end

  test "success: upsert to update a document", %{conn: conn, document: document} do
    {:ok, %{"id" => id}} = ExTypesense.create_document(conn, document)
    id = String.to_integer(id)
    company_name = "Stark Industries"

    updated_document =
      document
      |> Map.put(:company_name, company_name)
      |> Map.put(:id, id)

    {:ok, result} = ExTypesense.upsert_document(conn, updated_document)

    assert company_name === result["company_name"]
  end

  test "success: create document using upsert_document/2", %{conn: conn, document: document} do
    document = Map.put(document, :id, "9999")
    assert {:ok, %{"id" => "9999"}} = ExTypesense.upsert_document(conn, document)
  end

  test "error: creates a document with a specific id twice", %{conn: conn, document: document} do
    document = Map.put(document, :id, "99")
    assert {:ok, %{"id" => id}} = ExTypesense.create_document(conn, document)
    assert {:error, message} = ExTypesense.create_document(conn, document)
    assert message === "A document with id #{id} already exists."
  end

  test "success: update a document", %{conn: conn, document: document} do
    {:ok, %{"id" => id}} = ExTypesense.create_document(conn, document)
    company_name = "Stark Industries"

    updated_document =
      document
      |> Map.put(:company_name, company_name)
      |> Map.put(:id, id)

    {:ok, result} = ExTypesense.update_document(conn, updated_document)

    assert company_name === result["company_name"]
  end

  test "success: (deprecate) deletes a document using map", %{conn: conn, document: document} do
    {:ok, %{"id" => id}} = ExTypesense.create_document(conn, document)

    assert {:ok, _} = ExTypesense.delete_document(document.collection_name, String.to_integer(id))
  end

  test "success: deletes a document by struct", %{conn: conn} do
    person = %Person{id: 0, name: "Tar Zan", person_id: 0, country: "Brazil"}

    assert {:ok, %{"country" => "Brazil", "id" => "0", "name" => "Tar Zan", "person_id" => 0}} =
             ExTypesense.create_document(conn, person)

    assert {:ok, _} = ExTypesense.delete_document_by_struct(conn, person)
  end

  test "success: deletes a document by id", %{conn: conn, document: document} do
    {:ok, %{"id" => id}} = ExTypesense.create_document(conn, document)

    assert {:ok, _} =
             ExTypesense.delete_document_by_id(
               conn,
               document.collection_name,
               String.to_integer(id)
             )
  end

  test "success: index multiple documents", %{conn: conn, multiple_documents: multiple_documents} do
    conn
    |> ExTypesense.index_multiple_documents(multiple_documents)
    |> Kernel.===({:ok, [%{"success" => true}, %{"success" => true}]})
    |> assert()
  end

  test "success: update multiple documents", %{
    conn: conn,
    multiple_documents: multiple_documents,
    schema: schema
  } do
    first = Enum.at(multiple_documents.documents, 0) |> Map.put(:collection_name, schema.name)
    second = Enum.at(multiple_documents.documents, 1) |> Map.put(:collection_name, schema.name)
    first_update = "first_update"
    second_update = "second_update"

    {:ok, %{"id" => first_id}} = ExTypesense.create_document(conn, first)
    {:ok, %{"id" => second_id}} = ExTypesense.create_document(conn, second)

    update_1 =
      first
      |> Map.put(:id, first_id)
      |> Map.put(:company_name, first_update)

    update_2 =
      second
      |> Map.put(:id, second_id)
      |> Map.put(:company_name, second_update)

    multiple_documents = Map.put(multiple_documents, :documents, [update_1, update_2])

    conn
    |> ExTypesense.update_multiple_documents(multiple_documents)
    |> Kernel.===({:ok, [%{"success" => true}, %{"success" => true}]})
    |> assert()

    {:ok, first} = ExTypesense.get_document(conn, schema.name, String.to_integer(first_id))
    {:ok, second} = ExTypesense.get_document(conn, schema.name, String.to_integer(second_id))

    assert first["company_name"] === first_update
    assert second["company_name"] === second_update
  end

  test "success: upsert multiple documents", %{conn: conn, multiple_documents: multiple_documents} do
    conn
    |> ExTypesense.upsert_multiple_documents(multiple_documents)
    |> Kernel.===({:ok, [%{"success" => true}, %{"success" => true}]})
    |> assert()
  end

  test "error: upsert multiple documents with struct type" do
    persons = [
      %Person{id: 1, name: "John Smith"},
      %Person{id: 2, name: "Jane Smith"}
    ]

    assert {:error, ~s(It should be type of map, ":documents" key should contain list of maps)} ===
             ExTypesense.upsert_multiple_documents(persons)
  end
end
