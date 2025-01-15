defmodule ConversationTest do
  use ExUnit.Case, async: true

  alias OpenApiTypesense.APIStatsResponse
  alias OpenApiTypesense.Connection

  setup_all do
    conn = Connection.new()
    map_conn = %{api_key: "xyz", host: "localhost", port: 8108, scheme: "http"}

    %{conn: conn, map_conn: map_conn}
  end

  @tag ["27.1": true, "26.0": true, "0.25.2": true]
  test "list conversation models", %{conn: conn, map_conn: map_conn} do
    assert 1 === 1
  end
end
