defmodule ConversationTest do
  use ExUnit.Case, async: false

  alias OpenApiTypesense.ApiResponse
  alias OpenApiTypesense.CollectionResponse
  alias OpenApiTypesense.Connection

  setup_all do
    conn = Connection.new()
    map_conn = %{api_key: "xyz", host: "localhost", port: 8108, scheme: "http"}

    name = "conversation_store"

    schema =
      %{
        "name" => name,
        "fields" => [
          %{"name" => "conversation_id", "type" => "string"},
          %{"name" => "model_id", "type" => "string"},
          %{"name" => "timestamp", "type" => "int32"},
          %{"name" => "role", "type" => "string", "index" => false},
          %{"name" => "message", "type" => "string", "index" => false}
        ]
      }

    {:ok, %CollectionResponse{name: ^name}} = ExTypesense.create_collection(schema)

    on_exit(fn ->
      {:ok, %CollectionResponse{name: ^name}} = ExTypesense.drop_collection(name)
    end)

    %{conn: conn, map_conn: map_conn}
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "success: list conversation models", %{conn: conn, map_conn: map_conn} do
    assert {:ok, models} = ExTypesense.list_models()
    assert length(models) >= 0
    assert {:ok, _} = ExTypesense.list_models([])
    assert {:ok, _} = ExTypesense.list_models(conn: conn)
    assert {:ok, _} = ExTypesense.list_models(conn: map_conn)
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "error: get a non-existent conversation model", %{conn: conn, map_conn: map_conn} do
    assert {:error, %ApiResponse{message: "Model not found"}} =
             ExTypesense.get_model("non-existent")

    assert {:error, _} = ExTypesense.get_model("xyz", [])
    assert {:error, _} = ExTypesense.get_model("xyz", conn: conn)
    assert {:error, _} = ExTypesense.get_model("xyz", conn: map_conn)
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "success: delete a conversation model", %{conn: conn, map_conn: map_conn} do
    assert {:error, %ApiResponse{message: "Model not found"}} =
             ExTypesense.delete_model("non-existent")

    assert {:error, _} = ExTypesense.delete_model("xyz", [])
    assert {:error, _} = ExTypesense.delete_model("xyz", conn: conn)
    assert {:error, _} = ExTypesense.delete_model("xyz", conn: map_conn)
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "error: create a conversation model with incorrect API key", %{
    conn: conn,
    map_conn: map_conn
  } do
    body =
      %{
        "id" => "conv-model-1",
        "model_name" => "openai/gpt-3.5-turbo",
        "history_collection" => "conversation_store",
        "api_key" => "OPENAI_API_KEY",
        "system_prompt" =>
          "You are an assistant for question-answering. You can only make conversations based on the provided context. If a response cannot be formed strictly using the provided context, politely say you do not have knowledge about that topic.",
        "max_bytes" => 16_384
      }

    assert {:error, error} = ExTypesense.create_model(body)

    assert String.contains?(String.downcase(error.message), [
             "error",
             "incorrect",
             "parsing",
             "response",
             "timeout"
           ]) === true

    assert {:error, _} = ExTypesense.create_model(body, [])
    assert {:error, _} = ExTypesense.create_model(body, conn: conn)
    assert {:error, _} = ExTypesense.create_model(body, conn: map_conn)
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "error: update a conversation model with incorrect API key", %{
    conn: conn,
    map_conn: map_conn
  } do
    model_id = "conv-model-1"

    body =
      %{
        "id" => model_id,
        "model_name" => "openai/gpt-3.5-turbo",
        "history_collection" => "conversation_store",
        "api_key" => "OPENAI_API_KEY",
        "system_prompt" =>
          "Hey, you are an **intelligent** assistant for question-answering. You can only make conversations based on the provided context. If a response cannot be formed strictly using the provided context, politely say you do not have knowledge about that topic.",
        "max_bytes" => 16_384
      }

    assert {:error, %ApiResponse{message: _}} = ExTypesense.update_model(model_id, body)
    assert {:error, _} = ExTypesense.update_model(model_id, body)
    assert {:error, _} = ExTypesense.update_model(model_id, body, [])
    assert {:error, _} = ExTypesense.update_model(model_id, body, conn: conn)
    assert {:error, _} = ExTypesense.update_model(model_id, body, conn: map_conn)
  end
end
