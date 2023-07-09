defmodule CollectionTest do
  use ExUnit.Case, async: true

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

    on_exit(fn ->
      ExTypesense.drop_collection(schema.name)

      [:api_key, :host, :port, :scheme]
      |> Enum.each(&Application.delete_env(:ex_typesense, &1))
    end)

    %{schema: schema}
  end

  test "success: create and drop collection", %{schema: schema} do
    collection = ExTypesense.create_collection(schema)
    assert %ExTypesense.Collection{} = collection

    ExTypesense.drop_collection(schema.name)
    assert {:error, "Not Found"} === ExTypesense.get_collection(schema.name)
  end

  test "error: dropping unknown collection", %{schema: schema} do
    message = ~s(No collection with name `#{schema.name}` found.)
    assert {:error, message} === ExTypesense.drop_collection(schema.name)
  end

  test "success: get specific collection" do
  end

  test "error: get unknown collection", %{schema: schema} do
    assert {:error, "Not Found"} === ExTypesense.get_collection(schema.name)
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

  # test "success: update collection name" do
  # end

  test "success: count list of collections", %{schema: schema} do
    ExTypesense.create_collection(schema)
    refute ExTypesense.list_collections() |> Enum.empty?()
    ExTypesense.drop_collection(schema.name)
  end

  test "success: list aliases", %{schema: schema} do
    ExTypesense.upsert_collection_alias(schema.name, schema.name)
    count = length(ExTypesense.list_collection_aliases())
    assert count === 1

    ExTypesense.delete_collection_alias(schema.name)
  end

  test "success: create and delete alias", %{schema: schema} do
    collection_alias = ExTypesense.upsert_collection_alias(schema.name, schema.name)
    assert is_map(collection_alias) === true
    assert Enum.empty?(collection_alias) === false

    ExTypesense.delete_collection_alias(schema.name)
    assert {:error, "Not Found"} === ExTypesense.get_collection_alias(schema.name)
  end

  test "success: get collection name by alias", %{schema: schema} do
    %{"collection_name" => collection_name, "name" => collection_alias} =
      ExTypesense.upsert_collection_alias(schema.name, schema.name)

    assert collection_name === ExTypesense.get_collection_name(collection_alias)

    ExTypesense.delete_collection_alias(schema.name)
  end

  test "success: get specific alias", %{schema: schema} do
    ExTypesense.upsert_collection_alias(schema.name, schema.name)
    collection_alias = ExTypesense.get_collection_alias(schema.name)

    assert is_map(collection_alias)
    assert collection_alias["name"] === schema.name

    ExTypesense.delete_collection_alias(schema.name)
  end

  test "error: get unknown alias", %{schema: schema} do
    assert {:error, "Not Found"} === ExTypesense.get_collection_alias(schema.name)
  end

  test "error: delete unknown alias", %{schema: schema} do
    assert {:error, "Not Found"} === ExTypesense.delete_collection_alias(schema.name)
  end
end
