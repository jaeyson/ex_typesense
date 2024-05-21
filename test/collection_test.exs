defmodule CollectionTest do
  use ExUnit.Case, async: false

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

    %{conn: conn, schema: schema}
  end

  test "success: create and drop collection", %{conn: conn, schema: schema} do
    collection = ExTypesense.create_collection(conn, schema)
    assert %ExTypesense.Collection{} = collection

    ExTypesense.drop_collection(conn, schema.name)
    assert {:error, "Not Found"} === ExTypesense.get_collection(conn, schema.name)
  end

  test "error: dropping unknown collection", %{conn: conn, schema: schema} do
    message = ~s(No collection with name `#{schema.name}` found.)
    assert {:error, message} === ExTypesense.drop_collection(conn, schema.name)
  end

  test "success: get specific collection" do
  end

  test "error: get unknown collection", %{conn: conn, schema: schema} do
    assert {:error, "Not Found"} === ExTypesense.get_collection(conn, schema.name)
  end

  test "success: update schema fields", %{conn: conn, schema: schema} do
    ExTypesense.create_collection(conn, schema)

    fields = %{
      fields: [
        %{name: "company_name", drop: true},
        %{name: "test", type: "string"}
      ]
    }

    ExTypesense.update_collection_fields(conn, schema.name, fields)

    collection = ExTypesense.get_collection(conn, schema.name)

    test = Enum.find(collection.fields, fn map -> map["name"] === "test" end)

    assert test["name"] === "test"

    ExTypesense.drop_collection(conn, schema.name)
  end

  # test "success: update collection name" do
  # end

  test "success: count list of collections", %{conn: conn, schema: schema} do
    ExTypesense.create_collection(conn, schema)
    refute ExTypesense.list_collections(conn) |> Enum.empty?()
    ExTypesense.drop_collection(conn, schema.name)
  end

  test "success: list aliases", %{conn: conn, schema: schema} do
    ExTypesense.upsert_collection_alias(conn, schema.name, schema.name)
    count = length(ExTypesense.list_collection_aliases(conn))
    assert count === 1

    ExTypesense.delete_collection_alias(conn, schema.name)
  end

  test "success: create and delete alias", %{conn: conn, schema: schema} do
    collection_alias = ExTypesense.upsert_collection_alias(conn, schema.name, schema.name)
    assert is_map(collection_alias) === true
    assert Enum.empty?(collection_alias) === false

    ExTypesense.delete_collection_alias(conn, schema.name)
    assert {:error, "Not Found"} === ExTypesense.get_collection_alias(conn, schema.name)
  end

  test "success: get collection name by alias", %{conn: conn, schema: schema} do
    %{"collection_name" => collection_name, "name" => collection_alias} =
      ExTypesense.upsert_collection_alias(conn, schema.name, schema.name)

    assert collection_name === ExTypesense.get_collection_name(conn, collection_alias)

    ExTypesense.delete_collection_alias(conn, schema.name)
  end

  test "success: get specific alias", %{conn: conn, schema: schema} do
    ExTypesense.upsert_collection_alias(conn, schema.name, schema.name)
    collection_alias = ExTypesense.get_collection_alias(conn, schema.name)

    assert is_map(collection_alias)
    assert collection_alias["name"] === schema.name

    ExTypesense.delete_collection_alias(conn, schema.name)
  end

  test "error: get unknown alias", %{conn: conn, schema: schema} do
    assert {:error, "Not Found"} === ExTypesense.get_collection_alias(conn, schema.name)
  end

  test "error: delete unknown alias", %{conn: conn, schema: schema} do
    assert {:error, "Not Found"} === ExTypesense.delete_collection_alias(conn, schema.name)
  end
end
