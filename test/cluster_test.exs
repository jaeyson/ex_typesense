defmodule ClusterTest do
  use ExUnit.Case, async: false

  setup_all do
    [{:api_key, "xyz"}, {:host, "localhost"}, {:port, 8108}, {:scheme, "http"}]
    |> Enum.each(fn {key, val} -> Application.put_env(:ex_typesense, key, val) end)

    on_exit(fn ->
      [:api_key, :host, :port, :scheme]
      |> Enum.each(&Application.delete_env(:ex_typesense, &1))
    end)

    %{}
  end

  test "health" do
    assert {:ok, true} === ExTypesense.health()
  end

  test "api status" do
    api_status = ExTypesense.api_stats()
    assert :ok === elem(api_status, 0)
  end

  test "cluster metrics" do
    cluster_metrics = ExTypesense.cluster_metrics()
    assert :ok === elem(cluster_metrics, 0)
  end
end
