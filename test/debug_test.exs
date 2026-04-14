defmodule DebugTest do
  use ExUnit.Case, async: true

  alias OpenApiTypesense.Connection

  setup_all do
    conn = Connection.new()
    map_conn = %{api_key: "xyz", host: "localhost", port: 8108, scheme: "http"}

    %{conn: conn, map_conn: map_conn}
  end

  @tag ["30.0": true, "29.0": true, "28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "debug (v29.0)", %{conn: conn, map_conn: map_conn} do
    assert {:ok, %{"state" => 1, "version" => _version}} = ExTypesense.debug()
    assert {:ok, _} = ExTypesense.debug([])
    assert {:ok, _} = ExTypesense.debug(conn: conn)
    assert {:ok, _} = ExTypesense.debug(conn: map_conn)
  end
end
