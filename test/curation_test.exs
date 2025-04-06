defmodule CurationTest do
  use ExUnit.Case, async: true

  alias ExTypesense.TestSchema.House
  alias OpenApiTypesense.ApiResponse
  alias OpenApiTypesense.Connection
  alias OpenApiTypesense.SearchOverride
  alias OpenApiTypesense.SearchOverrideDeleteResponse
  alias OpenApiTypesense.SearchOverridesResponse

  setup_all do
    conn = Connection.new()
    map_conn = %{api_key: "xyz", host: "localhost", port: 8108, scheme: "http"}

    schema = %{
      name: "curate_companies",
      fields: [
        %{name: "company_name", type: "string"},
        %{name: "curate_companies_id", type: "int32"},
        %{name: "country", type: "string"}
      ],
      default_sorting_field: "curate_companies_id"
    }

    ExTypesense.create_collection(schema)
    ExTypesense.create_collection(House)

    on_exit(fn ->
      ExTypesense.drop_collection(schema.name)
      ExTypesense.drop_collection(House)
    end)

    %{schema: schema, conn: conn, map_conn: map_conn}
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "success: get override", %{schema: schema, conn: conn, map_conn: map_conn} do
    body =
      %{
        "rule" => %{
          "query" => "Grocter and Pamble",
          "match" => "exact"
        },
        "includes" => [
          %{"id" => "2", "position" => 44},
          %{"id" => "4", "position" => 10}
        ],
        "excludes" => [
          %{"id" => "117"}
        ]
      }

    name = "cust-company"

    assert {:ok, %SearchOverride{id: ^name}} =
             ExTypesense.upsert_override(schema.name, name, body)

    assert {:ok, _} = ExTypesense.upsert_override(schema.name, name, body, [])
    assert {:ok, _} = ExTypesense.upsert_override(conn, schema.name, name, body)
    assert {:ok, _} = ExTypesense.upsert_override(map_conn, schema.name, name, body)
    assert {:ok, _} = ExTypesense.upsert_override(conn, schema.name, name, body, [])
    assert {:ok, _} = ExTypesense.upsert_override(map_conn, schema.name, name, body, [])

    assert {:ok, %SearchOverride{id: ^name}} =
             ExTypesense.upsert_override(House, name, body)

    assert {:ok, _} = ExTypesense.upsert_override(House, name, body, [])
    assert {:ok, _} = ExTypesense.upsert_override(conn, House, name, body)
    assert {:ok, _} = ExTypesense.upsert_override(map_conn, House, name, body)
    assert {:ok, _} = ExTypesense.upsert_override(conn, House, name, body, [])
    assert {:ok, _} = ExTypesense.upsert_override(map_conn, House, name, body, [])

    assert {:ok, %SearchOverride{id: ^name}} = ExTypesense.get_override(schema.name, name)
    assert {:ok, _} = ExTypesense.get_override(schema.name, name, [])
    assert {:ok, _} = ExTypesense.get_override(conn, schema.name, name)
    assert {:ok, _} = ExTypesense.get_override(map_conn, schema.name, name)
    assert {:ok, _} = ExTypesense.get_override(conn, schema.name, name, [])
    assert {:ok, _} = ExTypesense.get_override(map_conn, schema.name, name, [])

    assert {:ok, %SearchOverride{id: ^name}} = ExTypesense.get_override(House, name)
    assert {:ok, _} = ExTypesense.get_override(House, name, [])
    assert {:ok, _} = ExTypesense.get_override(conn, House, name)
    assert {:ok, _} = ExTypesense.get_override(map_conn, House, name)
    assert {:ok, _} = ExTypesense.get_override(conn, House, name, [])
    assert {:ok, _} = ExTypesense.get_override(map_conn, House, name, [])
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "success: list all overrides", %{schema: schema, conn: conn, map_conn: map_conn} do
    assert {:ok, %SearchOverridesResponse{}} = ExTypesense.list_overrides(schema.name)
    assert {:ok, _} = ExTypesense.list_overrides(schema.name, [])
    assert {:ok, _} = ExTypesense.list_overrides(conn, schema.name)
    assert {:ok, _} = ExTypesense.list_overrides(map_conn, schema.name)
    assert {:ok, _} = ExTypesense.list_overrides(conn, schema.name, [])
    assert {:ok, _} = ExTypesense.list_overrides(map_conn, schema.name, [])

    assert {:ok, %SearchOverridesResponse{}} = ExTypesense.list_overrides(House)
    assert {:ok, _} = ExTypesense.list_overrides(House, [])
    assert {:ok, _} = ExTypesense.list_overrides(conn, House)
    assert {:ok, _} = ExTypesense.list_overrides(map_conn, House)
    assert {:ok, _} = ExTypesense.list_overrides(conn, House, [])
    assert {:ok, _} = ExTypesense.list_overrides(map_conn, House, [])
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "success: delete override", %{schema: schema, conn: conn, map_conn: map_conn} do
    body =
      %{
        "rule" => %{
          "query" => "duplex",
          "match" => "exact"
        },
        "includes" => [
          %{"id" => "21", "position" => 307},
          %{"id" => "82", "position" => 97}
        ],
        "excludes" => [
          %{"id" => "256"}
        ]
      }

    name = "cust-house"

    assert {:ok, %SearchOverride{id: ^name}} =
             ExTypesense.upsert_override(schema.name, name, body)

    assert {:ok, %SearchOverrideDeleteResponse{id: ^name}} =
             ExTypesense.delete_override(schema.name, name)

    assert {:error, %ApiResponse{message: "Could not find that `id`."}} =
             ExTypesense.delete_override(schema.name, name, [])

    assert {:error, _} = ExTypesense.delete_override(conn, schema.name, name)
    assert {:error, _} = ExTypesense.delete_override(map_conn, schema.name, name)
    assert {:error, _} = ExTypesense.delete_override(conn, schema.name, name, [])
    assert {:error, _} = ExTypesense.delete_override(map_conn, schema.name, name, [])

    assert {:ok, %SearchOverride{id: ^name}} =
             ExTypesense.upsert_override(House, name, body)

    assert {:ok, %SearchOverrideDeleteResponse{id: ^name}} =
             ExTypesense.delete_override(House, name)

    assert {:error, %ApiResponse{message: "Could not find that `id`."}} =
             ExTypesense.delete_override(House, name, [])

    assert {:error, _} = ExTypesense.delete_override(conn, House, name)
    assert {:error, _} = ExTypesense.delete_override(map_conn, House, name)
    assert {:error, _} = ExTypesense.delete_override(conn, House, name, [])
    assert {:error, _} = ExTypesense.delete_override(map_conn, House, name, [])
  end
end
