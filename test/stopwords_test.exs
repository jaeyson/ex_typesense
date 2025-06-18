defmodule StopwordsTest do
  use ExUnit.Case, async: true

  alias OpenApiTypesense.ApiResponse
  alias OpenApiTypesense.Connection
  alias OpenApiTypesense.StopwordsSetRetrieveSchema
  alias OpenApiTypesense.StopwordsSetSchema
  alias OpenApiTypesense.StopwordsSetsRetrieveAllSchema

  setup_all do
    conn = Connection.new()
    map_conn = %{api_key: "xyz", host: "localhost", port: 8108, scheme: "http"}

    on_exit(fn ->
      {:ok, %StopwordsSetsRetrieveAllSchema{stopwords: stopwords}} = ExTypesense.list_stopwords()

      stopwords
      |> Enum.each(fn stopword ->
        stop_id = stopword.id
        {:ok, %OpenApiTypesense.Stopwords{id: ^stop_id}} = ExTypesense.delete_stopword(stop_id)
      end)
    end)

    %{conn: conn, map_conn: map_conn}
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "success: get stopword", %{conn: conn, map_conn: map_conn} do
    stop_id = "stopword_set_countries"

    body =
      %{
        "stopwords" => ["Germany", "France", "Italy", "United States"],
        "locale" => "en"
      }

    assert {:ok, %StopwordsSetSchema{id: ^stop_id}} = ExTypesense.upsert_stopword(stop_id, body)
    assert {:ok, _} = ExTypesense.upsert_stopword(stop_id, body, [])
    assert {:ok, _} = ExTypesense.upsert_stopword(stop_id, body, conn: conn)
    assert {:ok, _} = ExTypesense.upsert_stopword(stop_id, body, conn: map_conn)

    assert {:ok, %StopwordsSetRetrieveSchema{stopwords: %{id: ^stop_id}}} =
             ExTypesense.get_stopword(stop_id)

    assert {:ok, _} = ExTypesense.get_stopword(stop_id)
    assert {:ok, _} = ExTypesense.get_stopword(stop_id, [])
    assert {:ok, _} = ExTypesense.get_stopword(stop_id, conn: conn)
    assert {:ok, _} = ExTypesense.get_stopword(stop_id, conn: map_conn)
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "success: list all stopwords", %{conn: conn, map_conn: map_conn} do
    assert {:ok, %StopwordsSetsRetrieveAllSchema{}} = ExTypesense.list_stopwords()
    assert {:ok, _} = ExTypesense.list_stopwords([])
    assert {:ok, _} = ExTypesense.list_stopwords(conn: conn)
    assert {:ok, _} = ExTypesense.list_stopwords(conn: map_conn)
  end

  @tag ["28.0": true, "27.1": true, "27.0": true, "26.0": true]
  test "success: delete stopword", %{conn: conn, map_conn: map_conn} do
    stop_id = "stopword_set_countries"

    body =
      %{
        "stopwords" => ["Germany", "France", "Italy", "United States"],
        "locale" => "en"
      }

    assert {:ok, %StopwordsSetSchema{id: ^stop_id}} = ExTypesense.upsert_stopword(stop_id, body)
    assert {:ok, %OpenApiTypesense.Stopwords{id: ^stop_id}} = ExTypesense.delete_stopword(stop_id)

    assert {:error, %ApiResponse{message: "Stopword `stopword_set_countries` not found."}} =
             ExTypesense.delete_stopword(stop_id, [])

    assert {:error, _} = ExTypesense.delete_stopword(stop_id, conn: conn)
    assert {:error, _} = ExTypesense.delete_stopword(stop_id, conn: map_conn)
  end
end
