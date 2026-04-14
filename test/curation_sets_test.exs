defmodule CurationSetsTest do
  use ExUnit.Case, async: true

  alias OpenApiTypesense.ApiResponse
  alias OpenApiTypesense.Connection
  alias OpenApiTypesense.CurationItemDeleteSchema
  alias OpenApiTypesense.CurationItemSchema
  alias OpenApiTypesense.CurationSetDeleteSchema
  alias OpenApiTypesense.CurationSetSchema

  setup_all do
    conn = Connection.new()
    map_conn = %{api_key: "xyz", host: "localhost", port: 8108, scheme: "http"}

    on_exit(fn ->
      curation_sets =
        case ExTypesense.retrieve_curation_sets() do
          {:ok, sets} ->
            sets

          {:error, _reason} ->
            []
        end

      if Enum.any?(curation_sets) do
        Enum.each(curation_sets, fn set ->
          {:ok, _set} = ExTypesense.delete_curation_set(set.name)
        end)
      end
    end)

    %{conn: conn, map_conn: map_conn}
  end

  @tag ["30.0": true]
  test "success: retrieve a curation set", %{conn: conn, map_conn: map_conn} do
    name = "curate_catalog"

    curation_set = %{
      "items" => [
        %{
          "id" => "customize-magazine",
          "rule" => %{
            "query" => "Fixie weekly",
            "match" => "exact"
          },
          "includes" => [
            %{"id" => "602", "position" => 1},
            %{"id" => "12", "position" => 2}
          ],
          "excludes" => [
            %{"id" => "999"}
          ]
        }
      ]
    }

    assert {:ok, %CurationSetSchema{name: ^name}} =
             ExTypesense.upsert_curation_set(name, curation_set)

    assert {:ok, %CurationSetSchema{name: ^name}} = ExTypesense.retrieve_curation_set(name)
    assert {:ok, %CurationSetSchema{name: ^name}} = ExTypesense.retrieve_curation_set(name, [])

    assert {:ok, %CurationSetSchema{name: ^name}} =
             ExTypesense.retrieve_curation_set(name, conn: conn)

    assert {:ok, %CurationSetSchema{name: ^name}} =
             ExTypesense.retrieve_curation_set(name, map_conn: map_conn)
  end

  @tag ["30.0": true]
  test "error: retrieve a non-existing curation set", %{conn: conn, map_conn: map_conn} do
    set_name = "unkown-set"
    error = {:error, %ApiResponse{message: "Curation index not found"}}
    assert ^error = ExTypesense.retrieve_curation_set(set_name)
    assert ^error = ExTypesense.retrieve_curation_set(set_name, [])
    assert ^error = ExTypesense.retrieve_curation_set(set_name, conn: conn)
    assert ^error = ExTypesense.retrieve_curation_set(set_name, map_conn: map_conn)
  end

  @tag ["30.0": true]
  test "error: retrieve a non-existing curation set item", %{conn: conn, map_conn: map_conn} do
    name = "curate_products_error"

    curation_set = %{
      "items" => [
        %{
          "id" => "customize-apple",
          "rule" => %{
            "query" => "apple",
            "match" => "exact"
          },
          "includes" => [
            %{"id" => "422", "position" => 1},
            %{"id" => "54", "position" => 2}
          ],
          "excludes" => [
            %{"id" => "287"}
          ]
        }
      ]
    }

    assert {:ok, %CurationSetSchema{name: ^name}} =
             ExTypesense.upsert_curation_set(name, curation_set)

    item_id = "unkown-item"
    error = {:error, %ApiResponse{message: "Not Found"}}
    assert ^error = ExTypesense.retrieve_curation_set_item(name, item_id)
    assert ^error = ExTypesense.retrieve_curation_set_item(name, item_id, [])
    assert ^error = ExTypesense.retrieve_curation_set_item(name, item_id, conn: conn)
    assert ^error = ExTypesense.retrieve_curation_set_item(name, item_id, map_conn: map_conn)
  end

  @tag ["30.0": true]
  test "error: retrieving an item_id with a whitespace on its name", %{
    conn: conn,
    map_conn: map_conn
  } do
    set_name = "curate_products"
    item_id = "white space"

    error =
      {:error, ~s(invalid request target: "/curation_sets/curate_products/items/white space")}

    assert ^error = ExTypesense.retrieve_curation_set_item(set_name, item_id)
    assert ^error = ExTypesense.retrieve_curation_set_item(set_name, item_id, [])
    assert ^error = ExTypesense.retrieve_curation_set_item(set_name, item_id, conn: conn)
    assert ^error = ExTypesense.retrieve_curation_set_item(set_name, item_id, map_conn: map_conn)
  end

  @tag ["30.0": true]
  test "success: list all curation sets", %{conn: conn, map_conn: map_conn} do
    name = "curate_products"

    curation_set = %{
      "items" => [
        %{
          "id" => "customize-apple",
          "rule" => %{
            "query" => "apple",
            "match" => "exact"
          },
          "includes" => [
            %{"id" => "422", "position" => 1},
            %{"id" => "54", "position" => 2}
          ],
          "excludes" => [
            %{"id" => "287"}
          ]
        }
      ]
    }

    assert {:ok, %CurationSetSchema{name: ^name}} =
             ExTypesense.upsert_curation_set(name, curation_set)

    assert {:ok, curation_sets} = ExTypesense.retrieve_curation_sets()
    assert Enum.any?(curation_sets)
    assert {:ok, _} = ExTypesense.retrieve_curation_sets([])
    assert {:ok, _} = ExTypesense.retrieve_curation_sets(conn: conn)
    assert {:ok, _} = ExTypesense.retrieve_curation_sets(map_conn: map_conn)
  end

  @tag ["30.0": true]
  test "success: list all curation set items", %{conn: conn, map_conn: map_conn} do
    set_name = "curate_products"

    curation_set = %{
      "items" => [
        %{
          "id" => "customize-apple",
          "rule" => %{
            "query" => "apple",
            "match" => "exact"
          },
          "includes" => [
            %{"id" => "422", "position" => 1},
            %{"id" => "54", "position" => 2}
          ],
          "excludes" => [
            %{"id" => "287"}
          ]
        }
      ]
    }

    assert {:ok, %CurationSetSchema{name: ^set_name}} =
             ExTypesense.upsert_curation_set(set_name, curation_set)

    item_id = "dynamic-sort-filter-demo"

    body = %{
      "rule" => %{
        "filter_by" => "store:={store}",
        "query" => "apple",
        "match" => "exact"
      },
      "remove_matched_tokens" => true,
      "sort_by" => "sales.{store}:desc, inventory.{store}:desc"
    }

    assert {:ok, %CurationItemSchema{id: ^item_id}} =
             ExTypesense.upsert_curation_set_item(set_name, item_id, body)

    assert {:ok, set_items} = ExTypesense.retrieve_curation_set_items(set_name)
    assert Enum.any?(set_items)
    assert {:ok, _set_items} = ExTypesense.retrieve_curation_set_items(set_name, [])
    assert {:ok, _set_items} = ExTypesense.retrieve_curation_set_items(set_name, conn: conn)

    assert {:ok, _set_items} =
             ExTypesense.retrieve_curation_set_items(set_name, map_conn: map_conn)
  end

  @tag ["30.0": true]
  test "success: create or update a curation set", %{conn: conn, map_conn: map_conn} do
    name = "curate_products"

    curation_set = %{
      "items" => [
        %{
          "id" => "customize-apple",
          "rule" => %{
            "query" => "apple",
            "match" => "exact"
          },
          "includes" => [
            %{"id" => "422", "position" => 1},
            %{"id" => "54", "position" => 2}
          ],
          "excludes" => [
            %{"id" => "287"}
          ]
        }
      ]
    }

    assert {:ok, %CurationSetSchema{name: ^name}} =
             ExTypesense.upsert_curation_set(name, curation_set)

    assert {:ok, %CurationSetSchema{name: ^name}} =
             ExTypesense.upsert_curation_set(name, curation_set, [])

    assert {:ok, %CurationSetSchema{name: ^name}} =
             ExTypesense.upsert_curation_set(name, curation_set, conn: conn)

    assert {:ok, %CurationSetSchema{name: ^name}} =
             ExTypesense.upsert_curation_set(name, curation_set, map_conn: map_conn)
  end

  @tag ["30.0": true]
  test "success: upsert a curation set item", %{conn: conn, map_conn: map_conn} do
    set_name = "curate_products"

    curation_set = %{
      "items" => [
        %{
          "id" => "customize-apple",
          "rule" => %{
            "query" => "apple",
            "match" => "exact"
          },
          "includes" => [
            %{"id" => "422", "position" => 1},
            %{"id" => "54", "position" => 2}
          ],
          "excludes" => [
            %{"id" => "287"}
          ]
        }
      ]
    }

    assert {:ok, %CurationSetSchema{name: ^set_name}} =
             ExTypesense.upsert_curation_set(set_name, curation_set)

    item_id = "dynamic-sort-filter"

    body = %{
      "rule" => %{
        "filter_by" => "store:={store}",
        "query" => "apple",
        "match" => "exact"
      },
      "remove_matched_tokens" => true,
      "sort_by" => "sales.{store}:desc, inventory.{store}:desc"
    }

    assert {:ok, %CurationItemSchema{id: ^item_id}} =
             ExTypesense.upsert_curation_set_item(set_name, item_id, body)

    assert {:ok, %CurationItemSchema{id: ^item_id}} =
             ExTypesense.upsert_curation_set_item(set_name, item_id, body, [])

    assert {:ok, %CurationItemSchema{id: ^item_id}} =
             ExTypesense.upsert_curation_set_item(set_name, item_id, body, conn: conn)

    assert {:ok, %CurationItemSchema{id: ^item_id}} =
             ExTypesense.upsert_curation_set_item(set_name, item_id, body, map_conn: map_conn)
  end

  @tag ["30.0": true]
  test "success: delete a curation set", %{conn: conn, map_conn: map_conn} do
    name = "curate_products_delete"

    curation_set = %{
      "items" => [
        %{
          "id" => "customize-apple",
          "rule" => %{
            "query" => "apple",
            "match" => "exact"
          },
          "includes" => [
            %{"id" => "422", "position" => 1},
            %{"id" => "54", "position" => 2}
          ],
          "excludes" => [
            %{"id" => "287"}
          ]
        }
      ]
    }

    assert {:ok, %CurationSetSchema{name: ^name}} =
             ExTypesense.upsert_curation_set(name, curation_set)

    assert {:ok, %CurationSetDeleteSchema{name: ^name}} = ExTypesense.delete_curation_set(name)

    error = {:error, %ApiResponse{message: "Curation index not found"}}
    assert ^error = ExTypesense.delete_curation_set(name, [])
    assert ^error = ExTypesense.delete_curation_set(name, conn: conn)
    assert ^error = ExTypesense.delete_curation_set(name, map_conn: map_conn)
  end

  @tag ["30.0": true]
  test "success: delete a curation set item", %{conn: conn, map_conn: map_conn} do
    name = "curate_products_item"

    curation_set = %{
      "items" => [
        %{
          "id" => "customize-apple",
          "rule" => %{
            "query" => "apple",
            "match" => "exact"
          },
          "includes" => [
            %{"id" => "422", "position" => 1},
            %{"id" => "54", "position" => 2}
          ],
          "excludes" => [
            %{"id" => "287"}
          ]
        }
      ]
    }

    assert {:ok, %CurationSetSchema{name: ^name}} =
             ExTypesense.upsert_curation_set(name, curation_set)

    item_id = "dynamic-sort-filter-item"

    body = %{
      "rule" => %{
        "filter_by" => "store:={store}",
        "query" => "apple",
        "match" => "exact"
      },
      "remove_matched_tokens" => true,
      "sort_by" => "sales.{store}:desc, inventory.{store}:desc"
    }

    assert {:ok, %CurationItemSchema{id: ^item_id}} =
             ExTypesense.upsert_curation_set_item(name, item_id, body)

    assert {:ok, %CurationItemDeleteSchema{id: ^item_id}} =
             ExTypesense.delete_curation_set_item(name, item_id)

    error = {:error, %ApiResponse{message: "Could not find that `id`."}}

    assert ^error = ExTypesense.delete_curation_set_item(name, item_id, [])
    assert ^error = ExTypesense.delete_curation_set_item(name, item_id, conn: conn)
    assert ^error = ExTypesense.delete_curation_set_item(name, item_id, map_conn: map_conn)
  end
end
