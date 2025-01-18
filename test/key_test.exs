defmodule KeyTest do
  use ExUnit.Case, async: true

  alias OpenApiTypesense.ApiKey
  alias OpenApiTypesense.ApiKeyDeleteResponse
  alias OpenApiTypesense.ApiKeysResponse
  alias OpenApiTypesense.Connection

  setup_all do
    conn = Connection.new()
    map_conn = %{api_key: "xyz", host: "localhost", port: 8108, scheme: "http"}

    api_key_schema = %{
      actions: ["documents:search"],
      collections: ["companies"],
      description: "Search-only companies key"
    }

    on_exit(fn ->
      {:ok, %ApiKeysResponse{keys: keys}} = ExTypesense.list_keys()

      keys
      |> Enum.each(fn key ->
        {:ok, %ApiKeyDeleteResponse{}} = ExTypesense.delete_key(key.id)
      end)
    end)

    %{api_key_schema: api_key_schema, conn: conn, map_conn: map_conn}
  end

  @tag ["27.1": true, "26.0": true, "0.25.2": true]
  test "success: get keys", %{api_key_schema: api_key_schema, conn: conn, map_conn: map_conn} do
    assert {:ok, api_key} = ExTypesense.create_key(api_key_schema)
    assert {:ok, _} = ExTypesense.create_key(api_key_schema, [])
    assert {:ok, _} = ExTypesense.create_key(conn, api_key_schema)
    assert {:ok, _} = ExTypesense.create_key(map_conn, api_key_schema)
    assert {:ok, _} = ExTypesense.create_key(conn, api_key_schema, [])
    assert {:ok, _} = ExTypesense.create_key(map_conn, api_key_schema, [])

    key_id = api_key.id

    assert {:ok, %ApiKey{id: ^key_id}} = ExTypesense.get_key(key_id)
    assert {:ok, %ApiKey{id: ^key_id}} = ExTypesense.get_key(key_id, [])
    assert {:ok, %ApiKey{id: ^key_id}} = ExTypesense.get_key(conn, key_id)
    assert {:ok, %ApiKey{id: ^key_id}} = ExTypesense.get_key(map_conn, key_id)
    assert {:ok, %ApiKey{id: ^key_id}} = ExTypesense.get_key(conn, key_id, [])
    assert {:ok, %ApiKey{id: ^key_id}} = ExTypesense.get_key(map_conn, key_id, [])
  end

  @tag ["27.1": true, "26.0": true, "0.25.2": true]
  test "success: delete keys", %{api_key_schema: api_key_schema, conn: conn, map_conn: map_conn} do
    assert {:ok, api_key} = ExTypesense.create_key(api_key_schema)
    key_id = api_key.id

    assert {:ok, %ApiKeyDeleteResponse{id: ^key_id}} = ExTypesense.delete_key(key_id)
    assert {:error, _} = ExTypesense.delete_key(key_id, [])
    assert {:error, _} = ExTypesense.delete_key(conn, key_id)
    assert {:error, _} = ExTypesense.delete_key(map_conn, key_id)
    assert {:error, _} = ExTypesense.delete_key(conn, key_id, [])
    assert {:error, _} = ExTypesense.delete_key(map_conn, key_id, [])
  end

  @tag ["27.1": true, "26.0": true, "0.25.2": true]
  test "success: list all keys", %{conn: conn, map_conn: map_conn} do
    assert {:ok, %ApiKeysResponse{}} = ExTypesense.list_keys()
    assert {:ok, _} = ExTypesense.list_keys([])
    assert {:ok, _} = ExTypesense.list_keys(conn)
    assert {:ok, _} = ExTypesense.list_keys(map_conn)
    assert {:ok, _} = ExTypesense.list_keys(conn, [])
    assert {:ok, _} = ExTypesense.list_keys(map_conn, [])
  end
end
