defmodule NaturalLanguageTest do
  use ExUnit.Case, async: true

  alias OpenApiTypesense.ApiResponse
  alias OpenApiTypesense.Connection
  alias OpenApiTypesense.NLSearchModelSchema

  setup_all do
    conn = Connection.new()
    map_conn = %{api_key: "xyz", host: "localhost", port: 8108, scheme: "http"}

    model = %{
      "id" => "gemini-model",
      "model_name" => "google/gemini-2.5-flash-lite",
      "api_key" => System.get_env("GOOGLE_GEMINI_API"),
      "max_bytes" => 16_000,
      "temperature" => 0.0
    }

    # TOO EXPENSIVE TO INVOKE FREE TIER REQUESTS!!!
    # on_exit(fn ->
    #   {:ok, models} = ExTypesense.retrieve_all_nl_search_models()

    #   models
    #   |> Enum.each(fn model ->
    #     model_id = model.id
    #     {:ok, %{id: ^model_id}} = ExTypesense.delete_nl_search_model(model.id)
    #   end)
    # end)

    %{conn: conn, map_conn: map_conn, model: model}
  end

  @tag [nls: true]
  test "success: create natural language search model", %{
    conn: conn,
    map_conn: map_conn,
    model: model
  } do
    case ExTypesense.create_nl_search_model(model) do
      {:error, error} ->
        assert String.contains?(String.downcase(error.message), [
                 "You exceeded your current quota",
                 "`api_key` is missing or is not a non-empty string.",
                 "already exists",
                 "please pass a valid api key",
                 "not found"
               ]) === true

        assert {:error, ^error} = ExTypesense.create_nl_search_model(model)
        assert {:error, ^error} = ExTypesense.create_nl_search_model(model, [])
        assert {:error, ^error} = ExTypesense.create_nl_search_model(model, conn: conn)
        assert {:error, ^error} = ExTypesense.create_nl_search_model(model, map_conn: map_conn)

      {:ok, %NLSearchModelSchema{id: id}} ->
        assert "gemini-model" === model["id"]
        assert {:error, error} = ExTypesense.create_nl_search_model(model)

        assert String.contains?(String.downcase(error.message), [
                 "You exceeded your current quota",
                 "`api_key` is missing or is not a non-empty string.",
                 "already exists",
                 "please pass a valid api key",
                 "not found"
               ]) === true

        assert {:error, ^error} = ExTypesense.create_nl_search_model(model, [])
        assert {:error, ^error} = ExTypesense.create_nl_search_model(model, conn: conn)
        assert {:error, ^error} = ExTypesense.create_nl_search_model(model, map_conn: map_conn)
    end
  end

  @tag [nls: true]
  test "error: delete unknown search model", %{conn: conn, map_conn: map_conn} do
    reason = %ApiResponse{message: "Model not found"}

    model_id = "unknown"

    assert {:error, ^reason} = ExTypesense.delete_nl_search_model(model_id)
    assert {:error, ^reason} = ExTypesense.delete_nl_search_model(model_id, [])
    assert {:error, ^reason} = ExTypesense.delete_nl_search_model(model_id, conn: conn)
    assert {:error, ^reason} = ExTypesense.delete_nl_search_model(model_id, map_conn: map_conn)
  end

  @tag [nls: true]
  test "success: retrieve all natural language search models", %{conn: conn, map_conn: map_conn} do
    case ExTypesense.retrieve_all_nl_search_models() do
      {:ok, []} ->
        assert {:ok, []} = ExTypesense.retrieve_all_nl_search_models()
        assert {:ok, []} = ExTypesense.retrieve_all_nl_search_models([])
        assert {:ok, []} = ExTypesense.retrieve_all_nl_search_models(conn: conn)
        assert {:ok, []} = ExTypesense.retrieve_all_nl_search_models(map_conn: map_conn)

      {:ok, [first | _]} when is_struct(first, NLSearchModelSchema) ->
        assert {:ok, _} = ExTypesense.retrieve_all_nl_search_models()
        assert {:ok, _} = ExTypesense.retrieve_all_nl_search_models([])
        assert {:ok, _} = ExTypesense.retrieve_all_nl_search_models(conn: conn)
        assert {:ok, _} = ExTypesense.retrieve_all_nl_search_models(map_conn: map_conn)
    end
  end

  @tag [nls: true]
  test "success: retrieve a natural language search model", %{
    conn: conn,
    map_conn: map_conn,
    model: model
  } do
    case ExTypesense.retrieve_nl_search_model(model["id"]) do
      {:error, reason} ->
        assert %ApiResponse{message: "Model not found"} === reason
        assert {:error, ^reason} = ExTypesense.retrieve_nl_search_model(model["id"])
        assert {:error, ^reason} = ExTypesense.retrieve_nl_search_model(model["id"], [])

        assert {:error, ^reason} =
                 ExTypesense.retrieve_nl_search_model(model["id"], conn: conn)

        assert {:error, ^reason} =
                 ExTypesense.retrieve_nl_search_model(model["id"], map_conn: map_conn)

      {:ok, %NLSearchModelSchema{id: id}} ->
        assert "gemini-model" === id

        assert {:ok, %NLSearchModelSchema{id: ^id}} =
                 ExTypesense.retrieve_nl_search_model(model["id"])

        assert {:ok, %NLSearchModelSchema{id: ^id}} =
                 ExTypesense.retrieve_nl_search_model(model["id"], [])

        assert {:ok, %NLSearchModelSchema{id: ^id}} =
                 ExTypesense.retrieve_nl_search_model(model["id"], conn: conn)

        assert {:ok, %NLSearchModelSchema{id: ^id}} =
                 ExTypesense.retrieve_nl_search_model(model["id"], map_conn: map_conn)
    end
  end

  @tag [nls: true]
  test "success: update a natural language search model", %{
    conn: conn,
    map_conn: map_conn,
    model: model
  } do
    body = %{
      "temperature" => 0.2,
      "system_prompt" => "New system prompt instructions"
    }

    ExTypesense.create_nl_search_model(model)

    case ExTypesense.update_nl_search_model(model["id"], body) do
      {:error, error} ->
        assert String.contains?(String.downcase(error.message), [
                 "You exceeded your current quota",
                 "`api_key` is missing or is not a non-empty string.",
                 "please pass a valid api key",
                 "not found"
               ]) === true

        assert {:error, ^error} = ExTypesense.update_nl_search_model(model["id"], body)
        assert {:error, ^error} = ExTypesense.update_nl_search_model(model["id"], body, [])

        assert {:error, ^error} =
                 ExTypesense.update_nl_search_model(model["id"], body, conn: conn)

        assert {:error, ^error} =
                 ExTypesense.update_nl_search_model(model["id"], body, map_conn: map_conn)

      {:ok, resp} ->
        model_id = resp.id

        assert {:ok, %NLSearchModelSchema{id: ^model_id}} =
                 ExTypesense.update_nl_search_model(model["id"], body)
    end
  end
end
