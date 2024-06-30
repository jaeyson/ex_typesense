defmodule ClusterTest do
  use ExUnit.Case, async: false

  setup_all do
    Application.put_all_env(
      ex_typesense: [
        api_key: "xyz",
        host: "localhost",
        port: 8108,
        scheme: "http"
      ]
    )

    on_exit(fn ->
      # this is for deprecated function to set the creds
      [:api_key, :host, :port, :scheme]
      |> Enum.each(&Application.delete_env(:ex_typesense, &1))
    end)

    :ok
  end

  test "health", context do
    assert {:ok, true} = ExTypesense.health()
    # assert_raise FunctionClauseError, fn ->
    #   ExTypesense.health()
    # end
    # assert_raise FunctionClauseError, fn ->
    #   Enum.chunk([1, 2, 3], 0)
    # end
  end

  test "health check with empty credentials" do
    conn = %{api_key: nil, host: nil, port: nil, scheme: nil}

    assert_raise FunctionClauseError, fn ->
      ExTypesense.health(conn)
    end
  end

  # test "health check, with incorrect API key" do
  #   conn = %{api_key: "abc", host: "localhost", port: 8109, scheme: "http"}
  #   assert {:ok, true} = ExTypesense.health(conn)
  # end

  test "api status" do
    assert {:ok, _} = ExTypesense.api_stats()
  end

  test "cluster metrics" do
    assert {:ok, _} = ExTypesense.cluster_metrics()
  end
end
