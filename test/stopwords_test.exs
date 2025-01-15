defmodule StopwordsTest do
  use ExUnit.Case, async: true

  alias OpenApiTypesense.ApiResponse
  alias OpenApiTypesense.Connection
  alias OpenApiTypesense.Stopwords
  alias OpenApiTypesense.StopwordsSetSchema
  alias OpenApiTypesense.StopwordsSetRetrieveSchema
  alias OpenApiTypesense.StopwordsSetsRetrieveAllSchema

  setup_all do
    conn = Connection.new()
    map_conn = %{api_key: "xyz", host: "localhost", port: 8108, scheme: "http"}

    %{conn: conn, map_conn: map_conn}
  end

  @tag ["27.1": true, "26.0": true, "0.25.2": true]
  test "success: get stopword", %{conn: conn, map_conn: map_conn} do
    stop_id = "stopword_set_countries"

    body =
      %{
        "stopwords" => ["Germany", "France", "Italy", "United States"],
        "locale" => "en"
      }

    assert {:ok, %StopwordsSetSchema{id: ^stop_id}} = ExTypesense.upsert_stopword(stop_id, body)
    assert {:ok, _} = ExTypesense.upsert_stopword(stop_id, body, [])
    assert {:ok, _} = ExTypesense.upsert_stopword(conn, stop_id, body)
    assert {:ok, _} = ExTypesense.upsert_stopword(map_conn, stop_id, body)
    assert {:ok, _} = ExTypesense.upsert_stopword(conn, stop_id, body, [])
    assert {:ok, _} = ExTypesense.upsert_stopword(map_conn, stop_id, body, [])

    assert {:ok, %StopwordsSetRetrieveSchema{stopwords: %{id: ^stop_id}}} =
             ExTypesense.get_stopword(stop_id)

    assert {:ok, _} = ExTypesense.get_stopword(stop_id)
    assert {:ok, _} = ExTypesense.get_stopword(stop_id, [])
    assert {:ok, _} = ExTypesense.get_stopword(conn, stop_id)
    assert {:ok, _} = ExTypesense.get_stopword(map_conn, stop_id)
    assert {:ok, _} = ExTypesense.get_stopword(conn, stop_id, [])
    assert {:ok, _} = ExTypesense.get_stopword(map_conn, stop_id, [])
  end

  @tag ["27.1": true, "26.0": true, "0.25.2": true]
  test "success: list all stopwords", %{conn: conn, map_conn: map_conn} do
    assert {:ok, %StopwordsSetsRetrieveAllSchema{}} = ExTypesense.list_stopwords()
    assert {:ok, _} = ExTypesense.list_stopwords([])
    assert {:ok, _} = ExTypesense.list_stopwords(conn)
    assert {:ok, _} = ExTypesense.list_stopwords(map_conn)
    assert {:ok, _} = ExTypesense.list_stopwords(conn, [])
    assert {:ok, _} = ExTypesense.list_stopwords(map_conn, [])
  end

  @tag ["27.1": true, "26.0": true, "0.25.2": true]
  test "success: delete stopword", %{conn: conn, map_conn: map_conn} do
    stop_id = "stopword_set_countries"

    body =
      %{
        "stopwords" => ["Germany", "France", "Italy", "United States"],
        "locale" => "en"
      }

    assert {:ok, %StopwordsSetSchema{id: ^stop_id}} = ExTypesense.upsert_stopword(stop_id, body)
    assert {:ok, %Stopwords{id: ^stop_id}} = ExTypesense.delete_stopword(stop_id)

    assert {:error, %ApiResponse{message: "Stopword `stopword_set_countries` not found."}} =
             ExTypesense.delete_stopword(stop_id, [])

    assert {:error, _} = ExTypesense.delete_stopword(conn, stop_id)
    assert {:error, _} = ExTypesense.delete_stopword(map_conn, stop_id)
    assert {:error, _} = ExTypesense.delete_stopword(conn, stop_id, [])
    assert {:error, _} = ExTypesense.delete_stopword(map_conn, stop_id, [])
  end
end
