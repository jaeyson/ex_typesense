defmodule StemmingTest do
  use ExUnit.Case, async: true

  alias OpenApiTypesense.ApiResponse
  alias OpenApiTypesense.CollectionResponse
  alias OpenApiTypesense.Connection
  alias OpenApiTypesense.StemmingDictionary

  setup_all do
    conn = Connection.new()
    map_conn = %{api_key: "xyz", host: "localhost", port: 8108, scheme: "http"}

    id = "irregular-plurals"

    schema = %{
      "name" => "stemming_companies",
      "fields" => [
        %{"name" => "description", "type" => "string", "stem_dictionary" => id},
        %{"name" => "companies_id", "type" => "int32"}
      ],
      "default_sorting_field" => "companies_id"
    }

    {:ok, %CollectionResponse{}} = ExTypesense.create_collection(schema)

    on_exit(fn ->
      ExTypesense.drop_collection(schema["name"])
    end)

    %{id: id, conn: conn, map_conn: map_conn}
  end

  @tag ["29.0": true, "28.0": true, "27.1": false, "27.0": false, "26.0": false]
  test "success: create stemming dictionaries", %{conn: conn, map_conn: map_conn} do
    id = "example-stemming"

    body = [
      %{"word" => "people", "root" => "person"},
      %{"word" => "children", "root" => "child"},
      %{"word" => "geese", "root" => "goose"}
    ]

    assert {:ok,
            [
              %{"root" => "person", "word" => "people"},
              %{"root" => "child", "word" => "children"},
              %{"root" => "goose", "word" => "geese"}
            ]} = ExTypesense.import_stemming_dictionary(body, id: id)

    assert {:ok,
            [
              %{"root" => "person", "word" => "people"},
              %{"root" => "child", "word" => "children"},
              %{"root" => "goose", "word" => "geese"}
            ]} = ExTypesense.import_stemming_dictionary(body, id: id, conn: conn)

    assert {:ok,
            [
              %{"root" => "person", "word" => "people"},
              %{"root" => "child", "word" => "children"},
              %{"root" => "goose", "word" => "geese"}
            ]} = ExTypesense.import_stemming_dictionary(body, id: id, conn: map_conn)
  end

  @tag ["29.0": true, "28.0": true, "27.1": false, "27.0": false, "26.0": false]
  test "success: list stemming dictionaries", %{conn: conn, map_conn: map_conn} do
    case ExTypesense.list_stemming_dictionaries() do
      {:ok, map} when is_map(map) ->
        assert {:ok, %{"dictionaries" => []}}

      {:ok, %OpenApiTypesense.Stemming{}} ->
        assert {:ok, %OpenApiTypesense.Stemming{}}
    end

    assert {:ok, _} = ExTypesense.list_stemming_dictionaries([])
    assert {:ok, _} = ExTypesense.list_stemming_dictionaries(conn: conn)
    assert {:ok, _} = ExTypesense.list_stemming_dictionaries(conn: map_conn)
  end

  @tag ["29.0": true, "28.0": true, "27.1": false, "27.0": false, "26.0": false]
  test "error: non-existent stemming dictionary" do
    assert {:error, %ApiResponse{message: message}} =
             ExTypesense.get_stemming_dictionary("non-existent")

    assert String.contains?(String.downcase(message), "not found") === true
  end

  @tag ["29.0": true, "28.0": true, "27.1": false, "27.0": false, "26.0": false]
  test "success: get specific stemming dictionary", %{id: id, conn: conn, map_conn: map_conn} do
    body = [
      %{"word" => "mice", "root" => "mouse"},
      %{"word" => "written", "root" => "write"},
      %{"word" => "driven", "root" => "drive"}
    ]

    assert {:ok,
            [
              %{"word" => "mice", "root" => "mouse"},
              %{"word" => "written", "root" => "write"},
              %{"word" => "driven", "root" => "drive"}
            ]} = ExTypesense.import_stemming_dictionary(body, id: id)

    assert {:ok, %StemmingDictionary{id: ^id}} = ExTypesense.get_stemming_dictionary(id)
    assert {:ok, %StemmingDictionary{id: ^id}} = ExTypesense.get_stemming_dictionary(id, [])

    assert {:ok, %StemmingDictionary{id: ^id}} =
             ExTypesense.get_stemming_dictionary(id, conn: conn)

    assert {:ok, %StemmingDictionary{id: ^id}} =
             ExTypesense.get_stemming_dictionary(id, conn: map_conn)
  end
end
