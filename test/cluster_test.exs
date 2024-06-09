defmodule ClusterTest do
  use ExUnit.Case, async: false

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

  test "health", context do
    assert {:ok, true} = ExTypesense.health(context.conn)
  end

  test "api status", context do
    assert {:ok, _} = ExTypesense.api_stats(context.conn)
  end

  test "cluster metrics", context do
    assert {:ok, _} = ExTypesense.cluster_metrics(context.conn)
  end
end
