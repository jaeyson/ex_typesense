defmodule DebugTest do
  use ExUnit.Case, async: true

  alias OpenApiTypesense.Connection
  alias OpenApiTypesense.Debug

  setup_all do
    conn = Connection.new()
    map_conn = %{api_key: "xyz", host: "localhost", port: 8108, scheme: "http"}

    %{conn: conn, map_conn: map_conn}
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "debug", %{conn: conn, map_conn: map_conn} do
    assert {:ok, %Debug{version: _}} = ExTypesense.debug()
    assert {:ok, _} = ExTypesense.debug([])
    assert {:ok, _} = ExTypesense.debug(conn)
    assert {:ok, _} = ExTypesense.debug(map_conn)
    assert {:ok, _} = ExTypesense.debug(conn, [])
    assert {:ok, _} = ExTypesense.debug(map_conn, [])
  end
end
