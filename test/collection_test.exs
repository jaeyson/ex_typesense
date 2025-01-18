defmodule CollectionTest do
  use ExUnit.Case, async: true

  alias ExTypesense.TestSchema.Product
  alias OpenApiTypesense.ApiResponse
  alias OpenApiTypesense.CollectionAlias
  alias OpenApiTypesense.CollectionAliasesResponse
  alias OpenApiTypesense.CollectionResponse
  alias OpenApiTypesense.CollectionUpdateSchema
  alias OpenApiTypesense.Connection

  setup_all do
    conn = Connection.new()
    map_conn = %{api_key: "xyz", host: "localhost", port: 8108, scheme: "http"}

    schema = %{
      name: "collection_companies",
      fields: [
        %{name: "company_name", type: "string"},
        %{name: "company_id", type: "int32"},
        %{name: "country", type: "string"}
      ],
      default_sorting_field: "company_id"
    }

    on_exit(fn ->
      ExTypesense.list_collections()
      |> then(fn {_, colls} -> colls end)
      |> Enum.each(&ExTypesense.drop_collection(&1.name))
    end)

    %{schema: schema, conn: conn, map_conn: map_conn}
  end

  setup %{schema: schema} do
    on_exit(fn ->
      ExTypesense.drop_collection(schema.name)
      ExTypesense.drop_collection(Product)
    end)

    :ok
  end

  @tag ["27.1": true, "26.0": true, "0.25.2": true]
  test "success: create collection", %{schema: schema, conn: conn, map_conn: map_conn} do
    name = schema.name
    prod_name = Product.__schema__(:source)
    assert {:ok, %CollectionResponse{name: ^name}} = ExTypesense.create_collection(schema)

    assert {:error, %ApiResponse{message: _already_exist}} =
             ExTypesense.create_collection(schema, [])

    assert {:error, %ApiResponse{message: _already_exist}} =
             ExTypesense.create_collection(conn, schema)

    assert {:error, %ApiResponse{message: _already_exist}} =
             ExTypesense.create_collection(map_conn, schema)

    assert {:error, %ApiResponse{message: _already_exist}} =
             ExTypesense.create_collection(conn, schema, [])

    assert {:error, %ApiResponse{message: _already_exist}} =
             ExTypesense.create_collection(map_conn, schema, [])

    assert {:ok, %CollectionResponse{name: ^prod_name}} = ExTypesense.create_collection(Product)

    assert {:error, %ApiResponse{message: _already_exist}} =
             ExTypesense.create_collection(Product, [])

    assert {:error, %ApiResponse{message: _already_exist}} =
             ExTypesense.create_collection(conn, Product)

    assert {:error, %ApiResponse{message: _already_exist}} =
             ExTypesense.create_collection(map_conn, Product)

    assert {:error, %ApiResponse{message: _already_exist}} =
             ExTypesense.create_collection(conn, Product, [])

    assert {:error, %ApiResponse{message: _already_exist}} =
             ExTypesense.create_collection(map_conn, Product, [])

    assert {:ok, %CollectionResponse{name: ^name}} = ExTypesense.get_collection(name)
    assert {:ok, %CollectionResponse{name: ^prod_name}} = ExTypesense.get_collection(Product)
  end

  @tag ["27.1": true, "26.0": true, "0.25.2": true]
  test "success: list all collections", %{conn: conn, map_conn: map_conn} do
    assert {:ok, _} = ExTypesense.list_collections()
    assert {:ok, _} = ExTypesense.list_collections(exclude_fields: "fields")
    assert {:ok, _} = ExTypesense.list_collections(conn)
    assert {:ok, _} = ExTypesense.list_collections(map_conn)
    assert {:ok, _} = ExTypesense.list_collections(conn, [])
    assert {:ok, _} = ExTypesense.list_collections(map_conn, [])
  end

  @tag ["27.1": true, "26.0": true, "0.25.2": true]
  test "success: clone collection", %{schema: schema, conn: conn, map_conn: map_conn} do
    name = schema.name
    prod_name = Product.__schema__(:source)

    assert {:ok, %CollectionResponse{name: ^name}} = ExTypesense.create_collection(schema)
    assert {:ok, %CollectionResponse{name: ^prod_name}} = ExTypesense.create_collection(Product)

    assert {:ok, %CollectionResponse{name: "new_u"}} = ExTypesense.clone_collection(name, "new_u")

    assert {:ok, %CollectionResponse{name: "new_v"}} =
             ExTypesense.clone_collection(name, "new_v", [])

    assert {:ok, %CollectionResponse{name: "new_w"}} =
             ExTypesense.clone_collection(conn, name, "new_w")

    assert {:ok, %CollectionResponse{name: "new_x"}} =
             ExTypesense.clone_collection(map_conn, name, "new_x")

    assert {:ok, %CollectionResponse{name: "new_y"}} =
             ExTypesense.clone_collection(conn, name, "new_y", [])

    assert {:ok, %CollectionResponse{name: "new_z"}} =
             ExTypesense.clone_collection(map_conn, name, "new_z", [])

    assert {:ok, %CollectionResponse{name: "prod_u"}} =
             ExTypesense.clone_collection(Product, "prod_u")

    assert {:ok, %CollectionResponse{name: "prod_v"}} =
             ExTypesense.clone_collection(Product, "prod_v", [])

    assert {:ok, %CollectionResponse{name: "prod_w"}} =
             ExTypesense.clone_collection(conn, Product, "prod_w")

    assert {:ok, %CollectionResponse{name: "prod_x"}} =
             ExTypesense.clone_collection(map_conn, Product, "prod_x")

    assert {:ok, %CollectionResponse{name: "prod_y"}} =
             ExTypesense.clone_collection(conn, Product, "prod_y", [])

    assert {:ok, %CollectionResponse{name: "prod_z"}} =
             ExTypesense.clone_collection(map_conn, Product, "prod_z", [])
  end

  @tag ["27.1": true, "26.0": true, "0.25.2": true]
  test "success: dropping collection won't affect alias", %{
    schema: schema,
    conn: conn,
    map_conn: map_conn
  } do
    name = schema.name
    prod_name = Product.__schema__(:source)

    assert {:ok, %CollectionResponse{}} = ExTypesense.create_collection(schema)
    assert {:ok, %CollectionResponse{}} = ExTypesense.create_collection(Product)

    assert {:ok,
            %CollectionAlias{
              collection_name: ^name,
              name: alias_name
            }} = ExTypesense.upsert_collection_alias(name <> "_alias", name)

    assert {:ok, _} = ExTypesense.upsert_collection_alias(name <> "_alias", name, [])
    assert {:ok, _} = ExTypesense.upsert_collection_alias(conn, name <> "_alias", name)
    assert {:ok, _} = ExTypesense.upsert_collection_alias(map_conn, name <> "_alias", name)
    assert {:ok, _} = ExTypesense.upsert_collection_alias(conn, name <> "_alias", name, [])
    assert {:ok, _} = ExTypesense.upsert_collection_alias(map_conn, name <> "_alias", name, [])

    assert {:ok,
            %CollectionAlias{
              collection_name: ^prod_name,
              name: alias_prod_name
            }} = ExTypesense.upsert_collection_alias(prod_name <> "_alias", Product)

    assert {:ok, %CollectionResponse{}} = ExTypesense.drop_collection(name)
    assert {:ok, %CollectionResponse{}} = ExTypesense.drop_collection(Product)

    assert {:error, %ApiResponse{message: "Not Found"}} = ExTypesense.get_collection(name)
    assert {:error, %ApiResponse{message: "Not Found"}} = ExTypesense.get_collection(Product)

    assert {:ok, %CollectionAlias{}} = ExTypesense.get_collection_alias(alias_name)
    assert {:ok, %CollectionAlias{}} = ExTypesense.get_collection_alias(alias_name, [])
    assert {:ok, %CollectionAlias{}} = ExTypesense.get_collection_alias(conn, alias_name)
    assert {:ok, %CollectionAlias{}} = ExTypesense.get_collection_alias(map_conn, alias_name)
    assert {:ok, %CollectionAlias{}} = ExTypesense.get_collection_alias(conn, alias_name, [])
    assert {:ok, %CollectionAlias{}} = ExTypesense.get_collection_alias(map_conn, alias_name, [])

    assert {:ok, %CollectionAlias{}} = ExTypesense.get_collection_alias(alias_prod_name)
    assert {:ok, %CollectionAlias{}} = ExTypesense.get_collection_alias(alias_prod_name, [])
    assert {:ok, %CollectionAlias{}} = ExTypesense.get_collection_alias(conn, alias_prod_name)
    assert {:ok, %CollectionAlias{}} = ExTypesense.get_collection_alias(map_conn, alias_prod_name)
    assert {:ok, %CollectionAlias{}} = ExTypesense.get_collection_alias(conn, alias_prod_name, [])

    assert {:ok, %CollectionAlias{}} =
             ExTypesense.get_collection_alias(map_conn, alias_prod_name, [])

    assert {:ok, %CollectionAliasesResponse{aliases: aliases}} =
             ExTypesense.list_collection_aliases()

    assert {:ok, _} = ExTypesense.list_collection_aliases([])
    assert {:ok, _} = ExTypesense.list_collection_aliases(conn)
    assert {:ok, _} = ExTypesense.list_collection_aliases(map_conn)
    assert {:ok, _} = ExTypesense.list_collection_aliases(conn, [])
    assert {:ok, _} = ExTypesense.list_collection_aliases(map_conn, [])

    assert aliases >= 0
  end

  @tag ["27.1": true, "26.0": true, "0.25.2": true]
  test "error: dropping unknown collection", %{conn: conn, map_conn: map_conn} do
    coll_name = "unknown"
    message = ~s(No collection with name `#{coll_name}` found.)

    assert {:error, %ApiResponse{message: ^message}} = ExTypesense.drop_collection(coll_name)
    assert {:error, %ApiResponse{}} = ExTypesense.drop_collection(coll_name, [])
    assert {:error, %ApiResponse{}} = ExTypesense.drop_collection(conn, coll_name)
    assert {:error, %ApiResponse{}} = ExTypesense.drop_collection(map_conn, coll_name)
    assert {:error, %ApiResponse{}} = ExTypesense.drop_collection(conn, coll_name, [])
    assert {:error, %ApiResponse{}} = ExTypesense.drop_collection(map_conn, coll_name, [])

    assert {:error, %ApiResponse{}} = ExTypesense.drop_collection(Product)
    assert {:error, %ApiResponse{}} = ExTypesense.drop_collection(Product, [])
    assert {:error, %ApiResponse{}} = ExTypesense.drop_collection(conn, Product)
    assert {:error, %ApiResponse{}} = ExTypesense.drop_collection(map_conn, Product)
    assert {:error, %ApiResponse{}} = ExTypesense.drop_collection(conn, Product, [])
    assert {:error, %ApiResponse{}} = ExTypesense.drop_collection(map_conn, Product, [])
  end

  @tag ["27.1": true, "26.0": true, "0.25.2": true]
  test "error: get unknown collection", %{conn: conn, map_conn: map_conn} do
    assert {:error, %ApiResponse{message: "Not Found"}} = ExTypesense.get_collection("xyz")
    assert {:error, %ApiResponse{message: "Not Found"}} = ExTypesense.get_collection(conn, "xyz")

    assert {:error, %ApiResponse{message: "Not Found"}} =
             ExTypesense.get_collection(map_conn, "xyz")

    assert {:error, %ApiResponse{message: "Not Found"}} = ExTypesense.get_collection(Product)

    assert {:error, %ApiResponse{message: "Not Found"}} =
             ExTypesense.get_collection(conn, Product)

    assert {:error, %ApiResponse{message: "Not Found"}} =
             ExTypesense.get_collection(map_conn, Product)
  end

  @tag ["27.1": true, "26.0": true, "0.25.2": true]
  test "success: dropping collection deletes all documents", %{schema: schema} do
    ExTypesense.create_collection(schema)

    multiple_documents = [
      %{company_name: "Noogle, Inc.", company_id: 56, country: "AO"},
      %{company_name: "Tikipedia", company_id: 62, country: "BD"}
    ]

    assert {:ok, _} = ExTypesense.import_documents(schema.name, multiple_documents)
    assert {:ok, %CollectionResponse{}} = ExTypesense.drop_collection(schema.name)

    assert {:error, %ApiResponse{message: "Not Found"}} =
             ExTypesense.get_document(schema.name, "1")
  end

  @tag ["27.1": true, "26.0": false, "0.25.2": false]
  test "success: update schema fields", %{schema: schema, conn: conn, map_conn: map_conn} do
    assert {:ok, %CollectionResponse{}} = ExTypesense.create_collection(schema)

    fields = %{
      fields: [
        %{name: "company_name", drop: true},
        %{name: "test", type: "string"}
      ]
    }

    assert {:ok, %CollectionUpdateSchema{}} =
             ExTypesense.update_collection_fields(schema.name, fields)

    assert {:error, %ApiResponse{}} =
             ExTypesense.update_collection_fields(schema.name, fields, [])

    assert {:error, %ApiResponse{}} =
             ExTypesense.update_collection_fields(conn, schema.name, fields)

    assert {:error, %ApiResponse{}} =
             ExTypesense.update_collection_fields(map_conn, schema.name, fields)

    assert {:error, %ApiResponse{}} =
             ExTypesense.update_collection_fields(conn, schema.name, fields, [])

    assert {:error, %ApiResponse{}} =
             ExTypesense.update_collection_fields(map_conn, schema.name, fields, [])

    assert {:error, %ApiResponse{}} = ExTypesense.update_collection_fields(Product, fields)
    assert {:error, %ApiResponse{}} = ExTypesense.update_collection_fields(Product, fields, [])
    assert {:error, %ApiResponse{}} = ExTypesense.update_collection_fields(conn, Product, fields)

    assert {:error, %ApiResponse{}} =
             ExTypesense.update_collection_fields(map_conn, Product, fields)

    assert {:error, %ApiResponse{}} =
             ExTypesense.update_collection_fields(map_conn, Product, fields)

    assert {:ok, collection} = ExTypesense.get_collection(schema.name)
    assert {:ok, _} = ExTypesense.get_collection(schema.name, [])
    assert {:ok, _} = ExTypesense.get_collection(conn, schema.name)
    assert {:ok, _} = ExTypesense.get_collection(map_conn, schema.name)
    assert {:ok, _} = ExTypesense.get_collection(conn, schema.name, [])
    assert {:ok, _} = ExTypesense.get_collection(map_conn, schema.name, [])

    assert {:error, _} = ExTypesense.get_collection(Product)
    assert {:error, _} = ExTypesense.get_collection(Product, [])
    assert {:error, _} = ExTypesense.get_collection(conn, Product)
    assert {:error, _} = ExTypesense.get_collection(map_conn, Product)
    assert {:error, _} = ExTypesense.get_collection(conn, Product, [])
    assert {:error, _} = ExTypesense.get_collection(map_conn, Product, [])

    test = Enum.find(collection.fields, fn map -> map.name === "test" end)

    assert test.name === "test"
  end

  @tag ["27.1": true, "26.0": true, "0.25.2": true]
  test "success: get collection name by alias", %{schema: schema, conn: conn, map_conn: map_conn} do
    name = schema.name

    assert {:ok, %CollectionResponse{name: ^name}} = ExTypesense.create_collection(schema)

    assert {:ok, %CollectionAlias{name: alias_name}} =
             ExTypesense.upsert_collection_alias(name <> "_alias", name)

    assert {:error, %ApiResponse{message: "Not Found"}} = ExTypesense.get_collection_name("xyz")
    assert {:ok, _} = ExTypesense.get_collection_name(alias_name)
    assert {:ok, _} = ExTypesense.get_collection_name(alias_name, [])
    assert {:ok, _} = ExTypesense.get_collection_name(conn, alias_name)
    assert {:ok, _} = ExTypesense.get_collection_name(map_conn, alias_name)
    assert {:ok, _} = ExTypesense.get_collection_name(conn, alias_name, [])
    assert {:ok, _} = ExTypesense.get_collection_name(map_conn, alias_name, [])
  end

  @tag ["27.1": true, "26.0": true, "0.25.2": true]
  test "success: create, get, delete alias", %{schema: schema, conn: conn, map_conn: map_conn} do
    name = schema.name

    assert {:ok, %CollectionResponse{}} = ExTypesense.create_collection(schema)

    assert {:ok, %CollectionAlias{name: alias_name}} =
             ExTypesense.upsert_collection_alias(name <> "_alias", name)

    assert {:ok, %CollectionAlias{}} = ExTypesense.get_collection_alias(alias_name)

    assert {:ok, %CollectionAlias{}} = ExTypesense.delete_collection_alias(alias_name)
    assert {:error, %ApiResponse{}} = ExTypesense.delete_collection_alias(alias_name, [])
    assert {:error, %ApiResponse{}} = ExTypesense.delete_collection_alias(conn, alias_name)
    assert {:error, %ApiResponse{}} = ExTypesense.delete_collection_alias(map_conn, alias_name)
    assert {:error, %ApiResponse{}} = ExTypesense.delete_collection_alias(conn, alias_name, [])

    assert {:error, %ApiResponse{}} =
             ExTypesense.delete_collection_alias(map_conn, alias_name, [])

    assert {:error, %ApiResponse{message: "Not Found"}} ===
             ExTypesense.get_collection_alias(alias_name)
  end
end
