defmodule ClusterTest do
  use ExUnit.Case, async: true

  test "health" do
    assert {:ok, true} = ExTypesense.health()
  end

  test "api status" do
    assert {:ok, _} = ExTypesense.api_stats()
  end

  test "cluster metrics" do
    assert {:ok, _} = ExTypesense.cluster_metrics()
  end
end
