defmodule ConnectionTest do
  use ExUnit.Case, async: true
  alias ExTypesense.TestSchema.Credential

  setup_all do
    %{
      conn: %ExTypesense.Connection{
        host: "localhost",
        api_key: "xyz",
        port: 8108,
        scheme: "http"
      }
    }
  end

  test "Using connection struct", context do
    assert {:ok, true} = ExTypesense.health(context.conn)
  end

  test "Using map" do
    conn = %{
      host: "localhost",
      api_key: "xyz",
      port: 8108,
      scheme: "http"
    }

    assert {:ok, true} = ExTypesense.health(conn)
  end

  test "Using a struct converted to map and update its keys" do
    conn = %Credential{
      node: "localhost",
      secret_key: "xyz",
      port: 8108,
      scheme: "http"
    }

    conn =
      conn
      |> Map.from_struct()
      |> Map.drop([:node, :secret_key])
      |> Map.put(:host, conn.node)
      |> Map.put(:api_key, conn.secret_key)

    assert {:ok, true} = ExTypesense.health(conn)
  end
end
