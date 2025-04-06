defmodule PresetTest do
  use ExUnit.Case, async: true

  alias OpenApiTypesense.ApiResponse
  alias OpenApiTypesense.Connection
  alias OpenApiTypesense.PresetDeleteSchema
  alias OpenApiTypesense.PresetSchema
  alias OpenApiTypesense.PresetsRetrieveSchema

  setup_all do
    conn = Connection.new()
    map_conn = %{api_key: "xyz", host: "localhost", port: 8108, scheme: "http"}

    %{conn: conn, map_conn: map_conn}
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "success: retrieve presets", %{conn: conn, map_conn: map_conn} do
    body =
      %{
        "value" => %{
          "searches" => [
            %{"collection" => "restaurants", "q" => "*", "sort_by" => "popularity"}
          ]
        }
      }

    name = "restaurant_view"

    assert {:ok, %PresetSchema{name: ^name}} = ExTypesense.upsert_preset(name, body)
    assert {:ok, _} = ExTypesense.upsert_preset(name, body, [])
    assert {:ok, _} = ExTypesense.upsert_preset(conn, name, body)
    assert {:ok, _} = ExTypesense.upsert_preset(map_conn, name, body)
    assert {:ok, _} = ExTypesense.upsert_preset(conn, name, body, [])
    assert {:ok, _} = ExTypesense.upsert_preset(map_conn, name, body, [])

    assert {:ok, %PresetSchema{name: ^name}} = ExTypesense.get_preset(name)
    assert {:ok, _} = ExTypesense.get_preset(name, [])
    assert {:ok, _} = ExTypesense.get_preset(conn, name)
    assert {:ok, _} = ExTypesense.get_preset(map_conn, name)
    assert {:ok, _} = ExTypesense.get_preset(conn, name, [])
    assert {:ok, _} = ExTypesense.get_preset(map_conn, name, [])
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "success: delete presets", %{conn: conn, map_conn: map_conn} do
    body =
      %{
        "value" => %{
          "searches" => [
            %{"collection" => "food_chains", "q" => "*", "sort_by" => "ratings"}
          ]
        }
      }

    name = "food_chain_view"

    {:ok, %PresetSchema{name: ^name}} = ExTypesense.upsert_preset(name, body)

    assert {:ok, %PresetDeleteSchema{name: ^name}} = ExTypesense.delete_preset(name)
    assert {:error, %ApiResponse{message: "Not found."}} = ExTypesense.delete_preset(name, [])
    assert {:error, _} = ExTypesense.delete_preset(conn, name)
    assert {:error, _} = ExTypesense.delete_preset(map_conn, name)
    assert {:error, _} = ExTypesense.delete_preset(conn, name, [])
    assert {:error, _} = ExTypesense.delete_preset(map_conn, name, [])
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "success: list all search presets", %{conn: conn, map_conn: map_conn} do
    assert {:ok, %PresetsRetrieveSchema{presets: _}} = ExTypesense.list_presets()
    assert {:ok, _} = ExTypesense.list_presets([])
    assert {:ok, _} = ExTypesense.list_presets(conn)
    assert {:ok, _} = ExTypesense.list_presets(map_conn)
    assert {:ok, _} = ExTypesense.list_presets(conn, [])
    assert {:ok, _} = ExTypesense.list_presets(map_conn, [])
  end
end
