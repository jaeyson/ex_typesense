defmodule DocumentTest do
  use ExUnit.Case, async: false

  alias ExTypesense.TestSchema.Person
  alias OpenApiTypesense.ApiResponse
  alias OpenApiTypesense.CollectionResponse
  alias OpenApiTypesense.Connection

  setup_all do
    conn = Connection.new()
    map_conn = %{api_key: "xyz", host: "localhost", port: 8108, scheme: "http"}

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

    multiple_documents = [
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

    ExTypesense.create_collection(schema)
    ExTypesense.create_collection(Person)

    on_exit(fn ->
      ExTypesense.drop_collection(schema.name)
      ExTypesense.drop_collection(Person)
    end)

    %{
      schema: schema,
      document: document,
      multiple_documents: multiple_documents,
      conn: conn,
      map_conn: map_conn
    }
  end

  setup %{schema: schema} do
    on_exit(fn ->
      ExTypesense.delete_all_documents(schema.name)
      ExTypesense.delete_all_documents(Person)
    end)

    :ok
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "error: get unknown document", %{schema: schema, conn: conn, map_conn: map_conn} do
    unknown_id = "999"
    message = ~s(Could not find a document with id: #{unknown_id})

    assert {:error, %ApiResponse{message: ^message}} =
             ExTypesense.get_document(Person, unknown_id)

    assert {:error, %ApiResponse{message: ^message}} =
             ExTypesense.get_document(schema.name, unknown_id)

    assert {:error, %ApiResponse{message: ^message}} =
             ExTypesense.get_document(Person, unknown_id, [])

    assert {:error, %ApiResponse{message: ^message}} =
             ExTypesense.get_document(schema.name, unknown_id, [])

    assert {:error, %ApiResponse{message: ^message}} =
             ExTypesense.get_document(Person, unknown_id, conn: conn)

    assert {:error, %ApiResponse{message: ^message}} =
             ExTypesense.get_document(schema.name, unknown_id, conn: conn)

    assert {:error, %ApiResponse{message: ^message}} =
             ExTypesense.get_document(Person, unknown_id, conn: map_conn)

    assert {:error, %ApiResponse{message: ^message}} =
             ExTypesense.get_document(schema.name, unknown_id, conn: map_conn)
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "success: index a document using a map then fetch if indexed", %{
    document: document,
    conn: conn,
    map_conn: map_conn
  } do
    person = %Person{
      name: "Rudolf Bidler",
      country: "ID",
      persons_id: 9_999
    }

    coll_name = document[:collection_name]

    assert {:ok, %{id: id, company_name: company_name}} = ExTypesense.index_document(document)
    assert {:ok, _} = ExTypesense.index_document(coll_name, document)
    assert {:ok, _} = ExTypesense.index_document(document, [])
    assert {:ok, _} = ExTypesense.index_document(document, conn: conn)
    assert {:ok, _} = ExTypesense.index_document(coll_name, document, conn: conn)
    assert {:ok, _} = ExTypesense.index_document(document, conn: map_conn)
    assert {:ok, _} = ExTypesense.index_document(coll_name, document, conn: map_conn)

    assert {:ok, %{id: _}} = ExTypesense.index_document(person)
    assert {:ok, _} = ExTypesense.index_document(person, [])
    assert {:ok, _} = ExTypesense.index_document(person, conn: conn)
    assert {:ok, _} = ExTypesense.index_document(person, conn: map_conn)

    assert {:ok, %{company_name: ^company_name}} = ExTypesense.get_document(coll_name, id)
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "success: adding unknown field", %{document: document} do
    document = Map.put(document, :unknown_field, "unknown_value")

    assert {:ok, %{id: id}} = ExTypesense.index_document(document)

    assert {:ok, %{id: ^id}} = ExTypesense.get_document(document.collection_name, id)
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "error: collection_name field removed in return value when indexing or updating", %{
    document: document
  } do
    document = Map.put(document, :company_name, "Index Industries")
    assert {:ok, %{id: id} = map} = ExTypesense.index_document(document)
    refute Map.has_key?(map, :collection_name)

    company_name = "Update Industries"

    updated_document =
      document
      |> Map.put(:company_name, company_name)
      |> Map.put(:id, id)

    assert {:ok, %{id: ^id, company_name: ^company_name} = updated_map} =
             ExTypesense.update_document(updated_document)

    refute Map.has_key?(updated_map, :collection_name)
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "success: upsert to update a document", %{document: document} do
    assert {:ok, %{id: id}} = ExTypesense.index_document(document)
    company_name = "Stark Industries"

    updated_document =
      document
      |> Map.put(:company_name, company_name)
      |> Map.put(:id, id)

    assert {:ok, %{id: ^id, company_name: ^company_name}} =
             ExTypesense.index_document(updated_document, action: "upsert")
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "error: creates a document with a specific id twice", %{document: document} do
    document = Map.put(document, :id, "99")
    assert {:ok, %{id: id}} = ExTypesense.index_document(document)
    message = "A document with id #{id} already exists."
    assert {:error, %ApiResponse{message: ^message}} = ExTypesense.index_document(document)
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "success: update a document", %{document: document, conn: conn, map_conn: map_conn} do
    assert {:ok, %{id: id}} = ExTypesense.index_document(document)

    company_name = "Stark Industries"

    updated_document =
      document
      |> Map.put(:company_name, company_name)
      |> Map.put(:id, id)

    assert {:ok, %{id: ^id, company_name: ^company_name}} =
             ExTypesense.update_document(updated_document)

    assert {:ok, _} = ExTypesense.update_document(updated_document, [])
    assert {:ok, _} = ExTypesense.update_document(updated_document, conn: conn)
    assert {:ok, _} = ExTypesense.update_document(updated_document, conn: map_conn)

    person = %Person{name: "Glark Cable", country: "SZ", persons_id: 233}

    assert {:ok, _} = ExTypesense.index_document(person)

    updated_struct = %{person | name: "Dobert Rowney Jr."}

    assert {:ok, %OpenApiTypesense.Documents{num_deleted: nil, num_updated: 1}} =
             ExTypesense.update_document(updated_struct)

    assert {:ok, _} =
             ExTypesense.update_document(updated_struct,
               filter_by: "persons_id:#{person.persons_id}"
             )

    assert {:ok, _} = ExTypesense.update_document(updated_struct, conn: conn)
    assert {:ok, _} = ExTypesense.update_document(updated_struct, conn: map_conn)
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "success: export documents", %{
    schema: schema,
    multiple_documents: multiple_documents,
    conn: conn,
    map_conn: map_conn
  } do
    persons = [
      %Person{name: "Chackie Jan", country: "BE", persons_id: 1_099},
      %Person{name: "Norbert de Rearo", country: "TD", persons_id: 48}
    ]

    assert {:ok, _} = ExTypesense.import_documents(schema.name, multiple_documents)
    assert {:ok, _} = ExTypesense.import_documents(Person, persons)

    assert {:ok, _} = ExTypesense.export_documents(schema.name)
    assert {:ok, _} = ExTypesense.export_documents(schema.name, [])
    assert {:ok, _} = ExTypesense.export_documents(schema.name, conn: conn)
    assert {:ok, _} = ExTypesense.export_documents(schema.name, conn: map_conn)

    assert {:ok, _} = ExTypesense.export_documents(Person)
    assert {:ok, _} = ExTypesense.export_documents(Person, [])
    assert {:ok, _} = ExTypesense.export_documents(Person, conn: conn)
    assert {:ok, _} = ExTypesense.export_documents(Person, conn: map_conn)
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "success: delete a document", %{
    schema: schema,
    document: document,
    conn: conn,
    map_conn: map_conn
  } do
    assert {:ok, %{id: id}} = ExTypesense.index_document(document)

    assert {:ok, %{id: ^id}} = ExTypesense.delete_document(schema.name, id)

    assert {:ok, %OpenApiTypesense.Documents{num_deleted: 0}} =
             ExTypesense.delete_document(document, [])

    assert {:ok, %OpenApiTypesense.Documents{num_deleted: 0}} =
             ExTypesense.delete_document(document, conn: conn)

    assert {:ok, %OpenApiTypesense.Documents{num_deleted: 0}} =
             ExTypesense.delete_document(document, conn: map_conn)

    assert {:error, _} = ExTypesense.delete_document(schema.name, id, ignore_not_found: false)
    assert {:error, _} = ExTypesense.delete_document(schema.name, id, conn: conn)
    assert {:error, _} = ExTypesense.delete_document(schema.name, id, conn: map_conn)

    opts = [conn: conn, ignore_not_found: false]
    assert {:error, _} = ExTypesense.delete_document(schema.name, id, opts)

    opts = [conn: map_conn, ignore_not_found: false]
    assert {:error, _} = ExTypesense.delete_document(schema.name, id, opts)

    person = %Person{name: "John Doe", persons_id: 1_111, country: "Scotland"}

    assert {:ok, _} = ExTypesense.index_document(person)

    assert {:ok, %OpenApiTypesense.Documents{num_deleted: 1}} =
             ExTypesense.delete_document(person)

    assert {:ok, %OpenApiTypesense.Documents{num_deleted: 0}} =
             ExTypesense.delete_document(person, [])

    assert {:ok, _} = ExTypesense.delete_document(person, conn: conn)
    assert {:ok, _} = ExTypesense.delete_document(person, conn: map_conn)
    assert {:ok, _} = ExTypesense.delete_document(person, ignore_not_found: true)
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "success: deletes a document by struct", %{conn: conn, map_conn: map_conn} do
    person = %Person{name: "John Smith", persons_id: 99, country: "Brazil"}

    assert {:ok, %{name: "John Smith", persons_id: 99, country: "Brazil"}} =
             ExTypesense.index_document(person)

    assert {:ok, %OpenApiTypesense.Documents{num_deleted: 1}} =
             ExTypesense.delete_document(person)

    assert {:ok, %OpenApiTypesense.Documents{num_deleted: 0}} =
             ExTypesense.delete_document(person, conn: conn)

    assert {:ok, _} = ExTypesense.delete_document(person, conn: map_conn)
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "success: index multiple documents", %{
    schema: schema,
    multiple_documents: multiple_documents,
    conn: conn,
    map_conn: map_conn
  } do
    assert {:ok, [%{"success" => true}, %{"success" => true}]} =
             ExTypesense.import_documents(schema.name, multiple_documents)

    assert {:ok, [%{"success" => true}, %{"success" => true}]} =
             ExTypesense.import_documents(schema.name, multiple_documents, [])

    assert {:ok, [%{"success" => true}, %{"success" => true}]} =
             ExTypesense.import_documents(schema.name, multiple_documents, conn: conn)

    assert {:ok, [%{"success" => true}, %{"success" => true}]} =
             ExTypesense.import_documents(schema.name, multiple_documents, conn: map_conn)

    persons = [
      %Person{name: "Chackie Jan", country: "BE", persons_id: 1_099},
      %Person{name: "Norbert de Rearo", country: "TD", persons_id: 48}
    ]

    assert {:ok, [%{"success" => true}, %{"success" => true}]} =
             ExTypesense.import_documents(Person, persons)

    assert {:ok, [%{"success" => true}, %{"success" => true}]} =
             ExTypesense.import_documents(Person, persons, [])

    assert {:ok, [%{"success" => true}, %{"success" => true}]} =
             ExTypesense.import_documents(Person, persons, conn: conn)

    assert {:ok, [%{"success" => true}, %{"success" => true}]} =
             ExTypesense.import_documents(Person, persons, conn: map_conn)
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "success: update multiple documents", %{
    multiple_documents: multiple_documents,
    schema: schema
  } do
    assert {:ok, %{id: first_id} = first} =
             ExTypesense.index_document(schema.name, Enum.at(multiple_documents, 0))

    assert {:ok, %{id: second_id} = second} =
             ExTypesense.index_document(schema.name, Enum.at(multiple_documents, 1))

    first_update = "first_update"
    second_update = "second_update"

    update_1 = %{first | id: first_id, company_name: first_update}
    update_2 = %{second | id: second_id, company_name: second_update}

    multiple_documents = [update_1, update_2]

    assert {:ok, [%{"success" => true}, %{"success" => true}]} =
             ExTypesense.import_documents(schema.name, multiple_documents, action: "update")

    assert {:ok, %{company_name: ^first_update}} = ExTypesense.get_document(schema.name, first_id)

    assert {:ok, %{company_name: ^second_update}} =
             ExTypesense.get_document(schema.name, second_id)
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "success: delete all documents using Ecto schema module", %{conn: conn, map_conn: map_conn} do
    person = %Person{name: "John Doe", persons_id: 1_111, country: "Scotland"}

    assert {:ok, _} = ExTypesense.index_document(person)

    assert {:ok, %OpenApiTypesense.Documents{num_deleted: 1, num_updated: nil}} =
             ExTypesense.delete_all_documents(Person)

    assert {:ok, _} = ExTypesense.delete_all_documents(Person, conn: conn)
    assert {:ok, _} = ExTypesense.delete_all_documents(Person, conn: map_conn)
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "success: deleting all documents won't drop the collection", %{
    schema: schema,
    conn: conn,
    map_conn: map_conn
  } do
    multiple_documents = [
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

    assert {:ok, [%{"success" => true}, %{"success" => true}]} ===
             ExTypesense.import_documents(schema.name, multiple_documents)

    assert {:ok, %{num_deleted: documents_deleted}} =
             ExTypesense.delete_all_documents(schema.name)

    assert {:ok, _} = ExTypesense.delete_all_documents(schema.name, conn: conn)
    assert {:ok, _} = ExTypesense.delete_all_documents(schema.name, conn: map_conn)

    assert documents_deleted > 0

    name = schema.name
    assert {:ok, %CollectionResponse{name: ^name}} = ExTypesense.get_collection(name)
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "success: update documents by query no change", %{
    schema: schema,
    multiple_documents: multiple_documents,
    conn: conn,
    map_conn: map_conn
  } do
    assert {:ok, _} = ExTypesense.import_documents(schema.name, multiple_documents)

    body = %{company_name: "Kakasaki"}
    opts = [filter_by: "id:!=''"]

    assert {:ok, %OpenApiTypesense.Documents{num_updated: 2}} =
             ExTypesense.update_documents_by_query(schema.name, body, opts)

    opts = Keyword.put(opts, :conn, conn)
    assert {:ok, _} = ExTypesense.update_documents_by_query(schema.name, body, opts)

    opts = Keyword.put(opts, :conn, map_conn)
    assert {:ok, _} = ExTypesense.update_documents_by_query(schema.name, body, opts)

    persons = [
      %Person{name: "Laniel Lay Dewis", country: "GY", persons_id: 466},
      %Person{name: "Dette Bavis", country: "HT", persons_id: 710}
    ]

    assert {:ok, _} = ExTypesense.import_documents(Person, persons)

    body = %{country: "LU"}

    assert {:ok, %OpenApiTypesense.Documents{num_updated: 2}} =
             ExTypesense.update_documents_by_query(Person, body, opts)

    assert {:ok, _} = ExTypesense.update_documents_by_query(Person, body, opts)
    assert {:ok, _} = ExTypesense.update_documents_by_query(Person, body, opts)
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "success: delete documents by query (Ecto schema)", %{conn: conn, map_conn: map_conn} do
    john_toe = %Person{name: "John Toe", persons_id: 32, country: "Egypt"}
    john_foe = %Person{name: "John Foe", persons_id: 14, country: "Cuba"}

    assert {:ok, %{country: "Egypt", name: "John Toe", persons_id: 32}} =
             ExTypesense.index_document(john_toe)

    assert {:ok, %{country: "Cuba", name: "John Foe", persons_id: 14}} =
             ExTypesense.index_document(john_foe)

    assert {:ok, %OpenApiTypesense.Documents{num_deleted: 2}} =
             ExTypesense.delete_documents_by_query(Person, filter_by: "persons_id:>=0")

    assert {:ok, %OpenApiTypesense.Documents{num_deleted: 0}} =
             ExTypesense.delete_documents_by_query(Person,
               filter_by: "persons_id:>=0",
               conn: conn
             )

    assert {:ok, %OpenApiTypesense.Documents{num_deleted: 0}} =
             ExTypesense.delete_documents_by_query(Person,
               filter_by: "persons_id:>=0",
               conn: map_conn
             )
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "success: delete documents by query (map)", %{schema: schema} do
    documents = [
      %{
        company_name: "Doctor & Gamble",
        doc_companies_id: 19,
        country: "ES"
      },
      %{
        company_name: "The Daily Bribe",
        doc_companies_id: 84,
        country: "PH"
      }
    ]

    assert {:ok, [%{"success" => true}, %{"success" => true}]} =
             ExTypesense.import_documents(schema.name, documents)

    assert {:ok, %OpenApiTypesense.Documents{num_deleted: 2}} =
             ExTypesense.delete_documents_by_query(schema.name, filter_by: "doc_companies_id:>=0")
  end
end
