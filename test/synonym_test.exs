defmodule SynonymTest do
  use ExUnit.Case, async: true

  alias ExTypesense.TestSchema.Car
  alias OpenApiTypesense.ApiResponse
  alias OpenApiTypesense.CollectionResponse
  alias OpenApiTypesense.Connection
  alias OpenApiTypesense.SearchSynonym
  alias OpenApiTypesense.SearchSynonymDeleteResponse
  alias OpenApiTypesense.SearchSynonymsResponse

  setup_all do
    conn = Connection.new()
    map_conn = %{api_key: "xyz", host: "localhost", port: 8108, scheme: "http"}

    schema = %{
      name: "clothes",
      fields: [
        %{name: "cloth_name", type: "string", facet: true},
        %{name: "clothes_id", type: "int32"}
      ],
      default_sorting_field: "clothes_id"
    }

    {:ok, %CollectionResponse{name: coll_name}} = ExTypesense.create_collection(schema)
    {:ok, _} = ExTypesense.create_collection(Car)

    on_exit(fn ->
      {:ok, _} = ExTypesense.drop_collection(coll_name)
      {:ok, _} = ExTypesense.drop_collection(Car)
    end)

    %{coll_name: coll_name, conn: conn, map_conn: map_conn}
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "upsert and list all synonyms", %{coll_name: coll_name, conn: conn, map_conn: map_conn} do
    body = %{
      "root" => "hat",
      "synonyms" => ["fedora", "cap", "visor"]
    }

    synonym_id = "hat-synonyms"

    assert {:ok, %SearchSynonym{id: ^synonym_id}} =
             ExTypesense.upsert_synonym(coll_name, synonym_id, body)

    assert {:ok, _} = ExTypesense.upsert_synonym(coll_name, synonym_id, body, conn: conn)
    assert {:ok, _} = ExTypesense.upsert_synonym(coll_name, synonym_id, body, conn: map_conn)

    body = %{
      "root" => "sedan",
      "synonyms" => ["saloon", "convertible", "automobile"]
    }

    synonym_id = "sedan-synonyms"

    assert {:ok, %SearchSynonym{id: ^synonym_id}} =
             ExTypesense.upsert_synonym(Car, synonym_id, body)

    assert {:ok, _} = ExTypesense.upsert_synonym(Car, synonym_id, body, [])
    assert {:ok, _} = ExTypesense.upsert_synonym(Car, synonym_id, body, conn: conn)
    assert {:ok, _} = ExTypesense.upsert_synonym(Car, synonym_id, body, conn: map_conn)

    assert {:ok, %SearchSynonymsResponse{}} = ExTypesense.list_synonyms(coll_name)
    assert {:ok, _} = ExTypesense.list_synonyms(coll_name, [])
    assert {:ok, _} = ExTypesense.list_synonyms(coll_name, conn: conn)
    assert {:ok, _} = ExTypesense.list_synonyms(coll_name, conn: map_conn)

    assert {:ok, %SearchSynonymsResponse{}} = ExTypesense.list_synonyms(Car)
    assert {:ok, _} = ExTypesense.list_synonyms(Car, [])
    assert {:ok, _} = ExTypesense.list_synonyms(Car, conn: conn)
    assert {:ok, _} = ExTypesense.list_synonyms(Car, conn: map_conn)
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "delete synonyms", %{coll_name: coll_name, conn: conn, map_conn: map_conn} do
    body = %{
      "root" => "hat",
      "synonyms" => ["fedora", "cap", "visor"]
    }

    syn_id = "hat-synonyms"

    assert {:ok, %SearchSynonym{id: ^syn_id}} =
             ExTypesense.upsert_synonym(coll_name, syn_id, body)

    assert {:ok, %SearchSynonym{id: ^syn_id}} = ExTypesense.get_synonym(coll_name, syn_id)
    assert {:ok, _} = ExTypesense.get_synonym(coll_name, syn_id, [])
    assert {:ok, _} = ExTypesense.get_synonym(coll_name, syn_id, conn: conn)
    assert {:ok, _} = ExTypesense.get_synonym(coll_name, syn_id, conn: map_conn)

    assert {:ok, %SearchSynonymDeleteResponse{id: ^syn_id}} =
             ExTypesense.delete_synonym(coll_name, syn_id)

    assert {:error, %ApiResponse{}} = ExTypesense.delete_synonym(coll_name, syn_id, [])
    assert {:error, %ApiResponse{}} = ExTypesense.delete_synonym(coll_name, syn_id, conn: conn)

    assert {:error, %ApiResponse{}} =
             ExTypesense.delete_synonym(coll_name, syn_id, conn: map_conn)

    body = %{
      "root" => "sedan",
      "synonyms" => ["saloon", "convertible", "automobile"]
    }

    syn_id = "sedan-synonyms"

    assert {:ok, %SearchSynonym{id: ^syn_id}} = ExTypesense.upsert_synonym(Car, syn_id, body)
    assert {:ok, %SearchSynonym{id: ^syn_id}} = ExTypesense.get_synonym(Car, syn_id)
    assert {:ok, _} = ExTypesense.get_synonym(Car, syn_id, [])
    assert {:ok, _} = ExTypesense.get_synonym(Car, syn_id, conn: conn)
    assert {:ok, _} = ExTypesense.get_synonym(Car, syn_id, conn: map_conn)

    assert {:ok, %SearchSynonymDeleteResponse{id: ^syn_id}} =
             ExTypesense.delete_synonym(Car, syn_id)

    assert {:error, %ApiResponse{}} = ExTypesense.delete_synonym(Car, syn_id, [])
    assert {:error, %ApiResponse{}} = ExTypesense.delete_synonym(Car, syn_id, conn: conn)
    assert {:error, %ApiResponse{}} = ExTypesense.delete_synonym(Car, syn_id, conn: map_conn)
  end
end
