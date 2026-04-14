defmodule SynonymTest do
  use ExUnit.Case, async: true

  alias ExTypesense.TestSchema.Car
  alias OpenApiTypesense.ApiResponse
  alias OpenApiTypesense.CollectionResponse
  alias OpenApiTypesense.Connection
  alias OpenApiTypesense.SearchSynonym
  alias OpenApiTypesense.SearchSynonymDeleteResponse
  alias OpenApiTypesense.SearchSynonymsResponse
  alias OpenApiTypesense.SynonymItemDeleteSchema
  alias OpenApiTypesense.SynonymItemSchema
  alias OpenApiTypesense.SynonymSetDeleteSchema
  alias OpenApiTypesense.SynonymSetSchema

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

  @tag ["29.0": true, "28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "success: upsert and list all synonyms", %{
    coll_name: coll_name,
    conn: conn,
    map_conn: map_conn
  } do
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

  @tag ["29.0": true, "28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "success: delete synonyms", %{coll_name: coll_name, conn: conn, map_conn: map_conn} do
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

  @tag ["30.0": true]
  test "error (v30.0): deprecated function for list collection synonyms", %{coll_name: coll_name} do
    error = {:error, %ApiResponse{message: "Not Found"}}
    assert ^error = ExTypesense.list_synonyms(coll_name)
    assert ^error = ExTypesense.list_synonyms(coll_name, [])
    assert ^error = ExTypesense.list_synonyms(Car)
    assert ^error = ExTypesense.list_synonyms(Car, [])
  end

  @tag ["30.0": true]
  test "error (v30.0): deprecated function for upsert a collection synonym", %{
    coll_name: coll_name
  } do
    body =
      %{
        "root" => "hat",
        "synonyms" => ["fedora", "cap", "visor"]
      }

    synonym_id = "hat-synonyms"

    error = {:error, %ApiResponse{message: "Not Found"}}
    assert ^error = ExTypesense.upsert_synonym(coll_name, synonym_id, body)
    assert ^error = ExTypesense.upsert_synonym(Car, synonym_id, body)
  end

  @tag ["30.0": true]
  test "error (v30.0): deprecated function for delete a collection synonym", %{
    coll_name: coll_name
  } do
    body =
      %{
        "root" => "sweater",
        "synonyms" => ["ribbed", "turtleneck", "v-neck", "half-zip"]
      }

    synonym_id = "sweater-synonyms"

    error = {:error, %ApiResponse{message: "Not Found"}}
    assert ^error = ExTypesense.upsert_synonym(coll_name, synonym_id, body)
    assert ^error = ExTypesense.upsert_synonym(coll_name, synonym_id, body, [])
  end

  @tag ["30.0": true]
  test "success: delete a synonym set item", %{conn: conn, map_conn: map_conn} do
    name = "tech-synonyms"

    body = %{
      "items" => [
        %{
          "id" => "smart-phone-synonyms",
          "root" => "smart phone",
          "synonyms" => ["iphone", "android"]
        }
      ]
    }

    assert {:ok, %SynonymSetSchema{name: ^name}} = ExTypesense.upsert_synonym_set(name, body)

    item_id = "smart-phone-synonyms"

    body = %{
      "root" => "smart phone",
      "synonyms" => ["iphone", "android"]
    }

    assert {:ok, %SynonymItemSchema{id: ^item_id}} =
             ExTypesense.upsert_synonym_set_item(name, item_id, body)

    assert {:ok, %SynonymItemDeleteSchema{id: ^item_id}} =
             ExTypesense.delete_synonym_set_item(name, item_id)

    error = {:error, %ApiResponse{message: "Could not find that `id`."}}
    assert ^error = ExTypesense.delete_synonym_set_item(name, item_id, [])
    assert ^error = ExTypesense.delete_synonym_set_item(name, item_id, conn: conn)
    assert ^error = ExTypesense.delete_synonym_set_item(name, item_id, map_conn: map_conn)
  end

  @tag ["30.0": true]
  test "error (v30.0): deprecate function delete a synonym associated with a collection", %{
    coll_name: coll_name
  } do
    synonym_id = "t-shirt-synonyms"
    error = {:error, %ApiResponse{message: "Not Found"}}
    assert ^error = ExTypesense.delete_synonym(coll_name, synonym_id)
    assert ^error = ExTypesense.delete_synonym(coll_name, synonym_id, [])
    assert ^error = ExTypesense.delete_synonym(Car, synonym_id)
    assert ^error = ExTypesense.delete_synonym(Car, synonym_id, [])
  end

  @tag ["30.0": true]
  test "success: list all synonym sets", %{conn: conn, map_conn: map_conn} do
    name = "sample"

    body = %{
      "items" => [
        %{
          "id" => "coat-synonyms",
          "synonyms" => ["blazer", "coat", "jacket"]
        }
      ]
    }

    assert {:ok, %SynonymSetSchema{name: ^name}} = ExTypesense.upsert_synonym_set(name, body)

    assert {:ok, synonym_sets} = ExTypesense.retrieve_synonym_sets()
    assert Enum.any?(synonym_sets)
    assert {:ok, _} = ExTypesense.retrieve_synonym_sets([])
    assert {:ok, _} = ExTypesense.retrieve_synonym_sets(conn: conn)
    assert {:ok, _} = ExTypesense.retrieve_synonym_sets(map_conn: map_conn)
  end

  @tag ["30.0": true]
  test "success: retrieve a synonym set", %{conn: conn, map_conn: map_conn} do
    name = "sample"

    body = %{
      "items" => [
        %{
          "id" => "coat-synonyms",
          "synonyms" => ["blazer", "coat", "jacket"]
        }
      ]
    }

    assert {:ok, %SynonymSetSchema{name: ^name}} = ExTypesense.upsert_synonym_set(name, body)
    assert {:ok, %SynonymSetSchema{name: ^name}} = ExTypesense.retrieve_synonym_set(name)
    assert {:ok, %SynonymSetSchema{name: ^name}} = ExTypesense.retrieve_synonym_set(name, [])

    assert {:ok, %SynonymSetSchema{name: ^name}} =
             ExTypesense.retrieve_synonym_set(name, conn: conn)

    assert {:ok, %SynonymSetSchema{name: ^name}} =
             ExTypesense.retrieve_synonym_set(name, map_conn: map_conn)
  end

  @tag ["30.0": true]
  test "success: retrieve a synonym set item", %{conn: conn, map_conn: map_conn} do
    name = "tech-synonyms"

    body = %{
      "items" => [
        %{
          "id" => "smart-phone-synonyms",
          "root" => "smart phone",
          "synonyms" => ["iphone", "android"]
        }
      ]
    }

    assert {:ok, %SynonymSetSchema{name: ^name}} = ExTypesense.upsert_synonym_set(name, body)

    item_id = "smart-phone-synonyms"

    body = %{
      "root" => "smart phone",
      "synonyms" => ["iphone", "android"]
    }

    assert {:ok, %SynonymItemSchema{id: ^item_id}} =
             ExTypesense.upsert_synonym_set_item(name, item_id, body)

    assert {:ok, %SynonymItemSchema{id: ^item_id}} =
             ExTypesense.retrieve_synonym_set_item(name, item_id)

    assert {:ok, %SynonymItemSchema{id: ^item_id}} =
             ExTypesense.retrieve_synonym_set_item(name, item_id, [])

    assert {:ok, %SynonymItemSchema{id: ^item_id}} =
             ExTypesense.retrieve_synonym_set_item(name, item_id, conn: conn)

    assert {:ok, %SynonymItemSchema{id: ^item_id}} =
             ExTypesense.retrieve_synonym_set_item(name, item_id, map_conn: map_conn)
  end

  @tag ["30.0": true]
  test "success: retrieve a synonym set items", %{conn: conn, map_conn: map_conn} do
    name = "tech-synonyms"

    body = %{
      "items" => [
        %{
          "id" => "smart-phone-synonyms",
          "root" => "smart phone",
          "synonyms" => ["iphone", "android"]
        }
      ]
    }

    assert {:ok, %SynonymSetSchema{name: ^name}} = ExTypesense.upsert_synonym_set(name, body)

    item_id = "smart-phone-synonyms"

    body = %{
      "root" => "smart phone",
      "synonyms" => ["iphone", "android"]
    }

    assert {:ok, %SynonymItemSchema{id: ^item_id}} =
             ExTypesense.upsert_synonym_set_item(name, item_id, body)

    assert {:ok, set_items} = ExTypesense.retrieve_synonym_set_items(name)
    assert Enum.any?(set_items)
    assert {:ok, _} = ExTypesense.retrieve_synonym_set_items(name, [])
    assert {:ok, _} = ExTypesense.retrieve_synonym_set_items(name, conn: conn)
    assert {:ok, _} = ExTypesense.retrieve_synonym_set_items(name, map_conn: map_conn)
  end

  @tag ["30.0": true]
  test "error (v30.0): deprecated function for get a collection synonym", %{coll_name: coll_name} do
    synonym_id = "t-shirt-synonyms"
    error = {:error, %ApiResponse{message: "Not Found"}}
    assert ^error = ExTypesense.get_synonym(coll_name, synonym_id)
    assert ^error = ExTypesense.get_synonym(coll_name, synonym_id, [])
    assert ^error = ExTypesense.get_synonym(Car, synonym_id)
    assert ^error = ExTypesense.get_synonym(Car, synonym_id, [])
  end

  @tag ["30.0": true]
  test "success: create or update a synonym set (multi-way synonym)", %{
    conn: conn,
    map_conn: map_conn
  } do
    name = "sample"

    body = %{
      "items" => [
        %{
          "id" => "coat-synonyms",
          "synonyms" => ["blazer", "coat", "jacket"]
        }
      ]
    }

    assert {:ok, %SynonymSetSchema{name: ^name}} = ExTypesense.upsert_synonym_set(name, body)
    assert {:ok, %SynonymSetSchema{name: ^name}} = ExTypesense.upsert_synonym_set(name, body, [])

    assert {:ok, %SynonymSetSchema{name: ^name}} =
             ExTypesense.upsert_synonym_set(name, body, conn: conn)

    assert {:ok, %SynonymSetSchema{name: ^name}} =
             ExTypesense.upsert_synonym_set(name, body, map_conn: map_conn)
  end

  @tag ["30.0": true]
  test "success: create or update a synonym set (one-way synonym)", %{
    conn: conn,
    map_conn: map_conn
  } do
    name = "tech-synonyms"

    body = %{
      "items" => [
        %{
          "id" => "smart-phone-synonyms",
          "root" => "smart phone",
          "synonyms" => ["iphone", "android"]
        }
      ]
    }

    assert {:ok, %SynonymSetSchema{name: ^name}} = ExTypesense.upsert_synonym_set(name, body)
    assert {:ok, %SynonymSetSchema{name: ^name}} = ExTypesense.upsert_synonym_set(name, body, [])

    assert {:ok, %SynonymSetSchema{name: ^name}} =
             ExTypesense.upsert_synonym_set(name, body, conn: conn)

    assert {:ok, %SynonymSetSchema{name: ^name}} =
             ExTypesense.upsert_synonym_set(name, body, map_conn: map_conn)
  end

  @tag ["30.0": true]
  test "success: upsert a synonym set item", %{conn: conn, map_conn: map_conn} do
    name = "tech-synonyms"

    body = %{
      "items" => [
        %{
          "id" => "smart-phone-synonyms",
          "root" => "smart phone",
          "synonyms" => ["iphone", "android"]
        }
      ]
    }

    assert {:ok, %SynonymSetSchema{name: ^name}} = ExTypesense.upsert_synonym_set(name, body)

    item_id = "smart-phone-synonyms"

    body = %{
      "root" => "smart phone",
      "synonyms" => ["iphone", "android"]
    }

    assert {:ok, %SynonymItemSchema{id: ^item_id}} =
             ExTypesense.upsert_synonym_set_item(name, item_id, body)

    assert {:ok, %SynonymItemSchema{id: ^item_id}} =
             ExTypesense.upsert_synonym_set_item(name, item_id, body, [])

    assert {:ok, %SynonymItemSchema{id: ^item_id}} =
             ExTypesense.upsert_synonym_set_item(name, item_id, body, conn: conn)

    assert {:ok, %SynonymItemSchema{id: ^item_id}} =
             ExTypesense.upsert_synonym_set_item(name, item_id, body, map_conn: map_conn)
  end

  @tag ["30.0": true]
  test "success: delete a synonym set", %{conn: conn, map_conn: map_conn} do
    name = "tech-synonyms"

    body = %{
      "items" => [
        %{
          "id" => "smart-phone-synonyms",
          "root" => "smart phone",
          "synonyms" => ["iphone", "android"]
        }
      ]
    }

    assert {:ok, %SynonymSetSchema{name: ^name}} = ExTypesense.upsert_synonym_set(name, body)
    assert {:ok, %SynonymSetDeleteSchema{name: ^name}} = ExTypesense.delete_synonym_set(name)

    error = {:error, %ApiResponse{message: "Synonym index not found"}}
    assert ^error = ExTypesense.delete_synonym_set(name, [])
    assert ^error = ExTypesense.delete_synonym_set(name, conn: conn)
    assert ^error = ExTypesense.delete_synonym_set(name, map_conn: map_conn)
  end
end
