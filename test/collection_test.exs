defmodule CollectionTest do
  use ExUnit.Case, async: true

  alias ExTypesense.TestSchema.Product

  setup_all do
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
      ExTypesense.drop_collection(schema.name)
      ExTypesense.drop_collection(Product)
    end)

    %{schema: schema}
  end

  test "success: create and drop collection", %{schema: schema} do
    products = ExTypesense.create_collection(Product)
    collection_companies = ExTypesense.create_collection(schema)

    assert %ExTypesense.Collection{} = products
    assert %ExTypesense.Collection{} = collection_companies

    ExTypesense.drop_collection(Product)
    assert {:error, "Not Found"} === ExTypesense.get_collection(Product)

    ExTypesense.drop_collection(schema.name)
    assert {:error, "Not Found"} === ExTypesense.get_collection(schema.name)
  end

  test "success: dropping collection won't affect alias", %{schema: schema} do
    assert %ExTypesense.Collection{} = ExTypesense.create_collection(Product)
    assert %ExTypesense.Collection{} = ExTypesense.create_collection(schema)

    assert %{"collection_name" => _collection_name, "name" => alias} =
             ExTypesense.upsert_collection_alias(schema.name <> "_alias", schema.name)

    ExTypesense.drop_collection(schema.name)
    ExTypesense.drop_collection(Product)

    assert {:error, "Not Found"} === ExTypesense.get_collection(schema.name)
    assert {:error, "Not Found"} === ExTypesense.get_collection(Product)

    assert %{"collection_name" => _collection_name, "name" => _alias} =
             ExTypesense.get_collection_alias(alias)
  end

  test "error: dropping unknown collection" do
    collection_name = "unknown"
    message = ~s(No collection with name `#{collection_name}` found.)
    assert {:error, message} === ExTypesense.drop_collection(collection_name)
  end

  test "success: get specific collection" do
    schema = %{
      name: "specific_collection",
      fields: [
        %{name: "collection_name", type: "string"},
        %{name: "collection_id", type: "int32"}
      ],
      default_sorting_field: "collection_id"
    }

    assert %ExTypesense.Collection{} = ExTypesense.create_collection(schema)
    collection = ExTypesense.get_collection(schema.name)
    assert collection.name === schema.name
    ExTypesense.drop_collection(schema.name)
  end

  test "error: get unknown collection" do
    assert {:error, "Not Found"} === ExTypesense.get_collection("unknown_collection_name")
  end

  test "success: update schema fields", %{schema: schema} do
    ExTypesense.create_collection(schema)

    fields = %{
      fields: [
        %{name: "company_name", drop: true},
        %{name: "test", type: "string"}
      ]
    }

    ExTypesense.update_collection_fields(schema.name, fields)

    collection = ExTypesense.get_collection(schema.name)

    test = Enum.find(collection.fields, fn map -> map["name"] === "test" end)

    assert test["name"] === "test"

    ExTypesense.drop_collection(schema.name)
  end

  # ISSUE: https://github.com/typesense/typesense/issues/1700
  # test "success: update collection name" do
  # end

  test "success: count list of collections", %{schema: schema} do
    ExTypesense.create_collection(schema)
    refute ExTypesense.list_collections() |> Enum.empty?()
    ExTypesense.drop_collection(schema.name)
  end

  test "success: list aliases", %{schema: schema} do
    assert %{"collection_name" => _collection_name, "name" => alias} =
             ExTypesense.upsert_collection_alias(schema.name <> "_alias", schema.name)

    refute Enum.empty?(ExTypesense.list_collection_aliases())

    assert %{"collection_name" => _collection_name, "name" => _alias} =
             ExTypesense.delete_collection_alias(alias)

    assert Enum.empty?(ExTypesense.list_collection_aliases())
  end

  test "success: create, get, delete alias", %{schema: schema} do
    assert %{"collection_name" => _collection_name, "name" => alias} =
             ExTypesense.upsert_collection_alias(schema.name <> "_alias", schema.name)

    assert %{"collection_name" => _collection_name, "name" => alias} =
             ExTypesense.get_collection_alias(alias)

    assert %{"collection_name" => _collection_name, "name" => alias} =
             ExTypesense.delete_collection_alias(alias)

    assert {:error, "Not Found"} === ExTypesense.get_collection_alias(alias)
  end

  test "error: get unknown alias" do
    assert {:error, "Not Found"} === ExTypesense.get_collection_alias("unknown_alias")
  end

  test "error: delete unknown alias" do
    assert {:error, "Not Found"} === ExTypesense.delete_collection_alias("unknown_alias")
  end
end
