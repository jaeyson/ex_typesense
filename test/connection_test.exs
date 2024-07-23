defmodule ConnectionTest do
  use ExUnit.Case, async: true
  alias ExTypesense.TestSchema.Credential

  @forbidden "Forbidden - a valid `x-typesense-api-key` header must be sent."

  setup_all do
    schema = %{
      name: "connection_companies",
      fields: [
        %{name: "company_name", type: "string"},
        %{name: "company_id", type: "int32"},
        %{name: "country", type: "string"}
      ],
      default_sorting_field: "company_id"
    }

    %{schema: schema}
  end

  setup %{schema: schema} do
    ExTypesense.create_collection(schema)

    on_exit(fn ->
      ExTypesense.drop_collection(schema.name)
    end)

    :ok
  end

  test "error: health check with empty credentials" do
    conn = %{api_key: nil, host: nil, port: nil, scheme: nil}

    assert_raise FunctionClauseError, fn ->
      ExTypesense.health(conn)
    end
  end

  test "error: health check, with incorrect port number" do
    conn = %{api_key: "abc", host: "localhost", port: 8100, scheme: "http"}

    assert_raise Req.TransportError, fn ->
      ExTypesense.health(conn)
    end
  end

  test "error: wrong api key was configured" do
    conn = %{
      host: "localhost",
      api_key: "another_key",
      port: 8108,
      scheme: "http"
    }

    assert {:error, @forbidden} == ExTypesense.list_collections(conn)
  end

  test "error: overriding config with a wrong API key" do
    conn = %{
      host: "localhost",
      api_key: "another_key",
      port: 8108,
      scheme: "http"
    }

    assert {:error, @forbidden} = ExTypesense.list_collections(conn)
  end

  test "success: health check" do
    assert {:ok, true} = ExTypesense.health()
  end

  test "success: Using a struct converted to map and update its keys" do
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
