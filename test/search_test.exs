defmodule SearchTest do
  use ExUnit.Case, async: true
  import Ecto.Query, warn: false

  alias ExTypesense.TestSchema.Catalog
  alias ExTypesense.TestSchema.MultiSearch
  alias ExTypesense.TestSchema.Truck
  alias OpenApiTypesense.ApiResponse
  alias OpenApiTypesense.CollectionResponse
  alias OpenApiTypesense.Connection
  alias OpenApiTypesense.MultiSearchResult
  alias OpenApiTypesense.SearchResult

  @embedding MultiSearch.vector_embeddings()

  setup_all do
    conn = Connection.new()
    map_conn = %{api_key: "xyz", host: "localhost", port: 8108, scheme: "http"}

    name = "shoes"

    schema =
      %{
        name: name,
        fields: [
          %{name: "shoe_type", type: "string"},
          %{name: "shoe_description_embedding", type: "float[]", num_dim: 1536},
          %{name: "#{name}_id", type: "int32"},
          %{name: "description", type: "string"},
          %{name: "price", type: "string"}
        ],
        default_sorting_field: "#{name}_id"
      }

    catalog = %Catalog{
      name: "Rubber Ducky",
      description: "A tool by articulating a problem in spoken or written natural language.",
      catalogs_id: 1002
    }

    {:ok, %CollectionResponse{name: ^name}} = ExTypesense.create_collection(schema)
    {:ok, %CollectionResponse{}} = ExTypesense.create_collection(Truck)

    with %CollectionResponse{} <- ExTypesense.create_collection(Catalog) do
      {:ok, _} = ExTypesense.index_document(catalog)
    end

    on_exit(fn ->
      {:ok, %CollectionResponse{name: ^name}} = ExTypesense.drop_collection(name)
      {:ok, %CollectionResponse{}} = ExTypesense.drop_collection(Truck)
      {:ok, %CollectionResponse{}} = ExTypesense.drop_collection(Catalog)
    end)

    %{catalog: catalog, coll_name: name, conn: conn, map_conn: map_conn}
  end

  @tag ["27.1": true, "27.0": true, "26.0": true]
  test "success: search a document", %{coll_name: coll_name, conn: conn, map_conn: map_conn} do
    shoes =
      [
        %{
          "shoes_id" => 333,
          "shoe_type" => "slipper",
          "description" => """
          UGG Men's Scuff Slipper
          - Full-grain leather upper
          - 17mm sheepskin insole
          - Foam footbed
          - Suede outsole
          - Recycled polyester binding
          """,
          "price" => "usd 89.95",
          "shoe_description_embedding" => @embedding
        },
        %{
          "shoes_id" => 888,
          "shoe_type" => "boot",
          "description" => """
          UGG Men's Classic Ultra Mini Boot
          - 17mm Twinface sheepskin upper
          - 17mm UGGplush upcycled wool insole
          - Treadlite by UGG outsole
          - Foam footbed
          """,
          "price" => "usd 149.95",
          "shoe_description_embedding" => @embedding
        }
      ]

    assert {:ok, [%{"success" => true}, %{"success" => true}]} =
             ExTypesense.import_documents(coll_name, shoes)

    shoes_opts = [q: "sheepskin", query_by: "description", enable_analytics: false]

    assert {:ok, %SearchResult{found: 2}} = ExTypesense.search(coll_name, shoes_opts)
    assert {:ok, _} = ExTypesense.search(conn, coll_name, shoes_opts)
    assert {:ok, _} = ExTypesense.search(map_conn, coll_name, shoes_opts)

    trucks = [
      %Truck{name: "pickup", trucks_id: 902},
      %Truck{name: "lorry", trucks_id: 20},
      %Truck{name: "camper", trucks_id: 866},
      %Truck{name: "off-road", trucks_id: 76},
      %Truck{name: "4x8 pickup", trucks_id: 902}
    ]

    assert {:ok, _} = ExTypesense.import_documents(Truck, trucks)

    trucks_opts = [q: "pickup", query_by: "name", enable_analytics: false]

    assert {:ok, %SearchResult{found: 2}} = ExTypesense.search(Truck, trucks_opts)
    assert {:ok, %SearchResult{found: 2}} = ExTypesense.search(conn, Truck, trucks_opts)
    assert {:ok, %SearchResult{found: 2}} = ExTypesense.search(map_conn, Truck, trucks_opts)
  end

  @tag ["27.1": true, "27.0": true, "26.0": true]
  test "success: search with empty result", %{coll_name: coll_name} do
    params = %{
      q: "test",
      query_by: "shoe_type"
    }

    assert {:ok, %SearchResult{found: 0}} = ExTypesense.search(coll_name, params)
  end

  @tag ["27.1": true, "27.0": true, "26.0": true]
  test "success: search with Ecto", %{catalog: catalog, conn: conn, map_conn: map_conn} do
    params = [q: "duck", query_by: "name"]

    catalog_coll_name = Catalog.__schema__(:source)

    assert %Ecto.Query{} = Catalog |> where([p], p.id in ^[catalog.catalogs_id])

    assert %Ecto.Query{from: %Ecto.Query.FromExpr{source: {^catalog_coll_name, _}}} =
             ExTypesense.search_ecto(Catalog, params)

    assert %Ecto.Query{} = ExTypesense.search_ecto(conn, Catalog, params)
    assert %Ecto.Query{} = ExTypesense.search_ecto(map_conn, Catalog, params)
  end

  @tag ["27.1": true, "27.0": true, "26.0": true]
  test "success: multi_search Ecto", %{conn: conn, map_conn: map_conn} do
    searches = [
      %{collection: Catalog, q: "duck", query_by: "name"},
      %{"collection" => "catalogs", "q" => "umbrella", "query_by" => "name"}
    ]

    assert [%Ecto.Query{}, %Ecto.Query{}] = ExTypesense.multi_search_ecto(searches)
    assert [%Ecto.Query{} | _] = ExTypesense.multi_search_ecto(searches, [])
    assert [%Ecto.Query{} | _] = ExTypesense.multi_search_ecto(conn, searches)
    assert [%Ecto.Query{} | _] = ExTypesense.multi_search_ecto(map_conn, searches)
    assert [%Ecto.Query{} | _] = ExTypesense.multi_search_ecto(conn, searches, [])
    assert [%Ecto.Query{} | _] = ExTypesense.multi_search_ecto(map_conn, searches, [])
  end

  @tag ["27.1": true, "27.0": true, "26.0": true]
  test "success: search with 1 Ecto query result" do
    catalog = %Catalog{
      name: "Rubber Ducks in Bulk",
      description: "Assortment Duckies for Jeep Ducking Floater Duck Bath Toys Party Favors",
      catalogs_id: 383
    }

    assert {:ok, _} = ExTypesense.index_document(catalog)

    params = [q: "bulk", query_by: "name"]

    coll_name = Catalog.__schema__(:source)

    assert {:ok, %SearchResult{found: 1}} = ExTypesense.search(Catalog, params)

    assert %Ecto.Query{from: %Ecto.Query.FromExpr{source: {^coll_name, nil}}} =
             ExTypesense.search_ecto(Catalog, params)
  end

  @tag ["27.1": true, "27.0": true, "26.0": true]
  test "success: multi_search string or module collection name" do
    catalog = %Catalog{
      name: "60 Pcs Mini Resin Ducks",
      description: "Luminous Tiny Ducks Miniature Duck Glow in The Dark for DIY Garden",
      catalogs_id: 192
    }

    {:ok, _} = ExTypesense.index_document(catalog)

    searches = [
      %{collection: Catalog, q: "resin", query_by: "name"},
      %{"collection" => Catalog, "q" => "resin", "query_by" => "name"}
    ]

    assert {:ok, %MultiSearchResult{results: [%{found: 1}, %{found: 1}]}} =
             ExTypesense.multi_search(searches)
  end

  @tag ["27.1": true, "27.0": true, "26.0": true]
  test "success: multi_search (vector) with result", %{coll_name: coll_name} do
    shoes =
      [
        %{
          "shoes_id" => 2_858,
          "shoe_type" => "athletic",
          "description" => """
          Kricely Men's Walking Shoes Breathable Lightweight Fashion Sneakers Non Slip Sport Gym Jogging Trail Running Shoes
          - Fashion Knitted Mesh Upper:Mesh upper offers a snug, sock-like fit, comfortable, breathable and lightweight the upper and let your foot always keeps dry and cool.
          - The colorful and unique fashion design can make the person wearing him become the coolest person on the whole street, attracting everyone's attention.
          - Rubber material of sole possesses high durability for prolonging the wearing time of our shoes.
          - Slip-resistant and wear-resistant:The rubber sole of the running shoes for men has good abrasion resistance, and the groove texture design increases the anti-skid performance of the sole.
          - Applicable occasions: The mens fashion sneakers are uitable for all kinds of sports and daily wear, such as jogging, walking, running, gym workout, sports, travel, athletic， outdoor, exercise, hiking, camping, casual, daily shopping, driving and any other occasion.
          """,
          "price" => "usd 51.99",
          "shoe_description_embedding" => @embedding
        },
        %{
          "shoes_id" => 831,
          "shoe_type" => "athletic",
          "description" => """
          Adidas Unisex-Adult Samba Indoor Sneaker
          - Performance soccer shoes for playing on indoor surfaces, casual, sports
          - SOCCER SIZING: Unisex product is men's sizing. Women should size down 1 to 1.5 sizes
          - LEATHER UPPER: Leather upper with suede overlays for comfort and soft feel
          - SYNTHETIC LINING: Synthetic lining provides a soft, comfortable feel
          - INDOOR SOCCER OUTSOLE: The grippy rubber outsole is specially designed for flat indoor surfaces
          """,
          "price" => "usd 89.95",
          "shoe_description_embedding" => @embedding
        }
      ]

    assert {:ok, [%{"success" => true}, %{"success" => true}]} =
             ExTypesense.import_documents(coll_name, shoes)

    searches = [
      %{
        collection: coll_name,
        q: "athletic",
        query_by: "shoe_type",
        vector_query:
          "shoe_description_embedding:([#{@embedding |> Enum.map_join(", ", &Float.to_string/1)}], k:100)",
        exclude_fields: "shoe_description_embedding"
      }
    ]

    assert {:ok, %MultiSearchResult{results: results}} = ExTypesense.multi_search(searches)

    assert [%{found: _, hits: hits} | _rest] = results

    assert [
             %{
               document: %{shoe_type: "athletic"},
               vector_distance: _some_number
             }
             | _rest
           ] = hits
  end

  @tag ["27.1": true, "27.0": true, "26.0": true]
  test "error: multi-search with no documents", %{conn: conn, map_conn: map_conn} do
    searches = [
      %{"collection" => "shoes", "q" => "Nike", "query_by" => "description"},
      %{"collection" => "shoes", "q" => "Timberland", "query_by" => "description"}
    ]

    assert {:ok, %MultiSearchResult{results: [%{found: 0}, %{found: 0}]}} =
             ExTypesense.multi_search(searches)

    params = [enable_analytics: false]

    assert {:ok, _} = ExTypesense.multi_search(searches, params)
    assert {:ok, _} = ExTypesense.multi_search(conn, searches)
    assert {:ok, _} = ExTypesense.multi_search(map_conn, searches)
    assert {:ok, _} = ExTypesense.multi_search(conn, searches, params)
    assert {:ok, _} = ExTypesense.multi_search(map_conn, searches, params)
  end

  @tag ["27.1": true, "27.0": true, "26.0": true]
  test "error: multi_search with vector_search by an id that doesn't exist", %{
    coll_name: coll_name
  } do
    searches = [
      %{
        collection: coll_name,
        q: "*",
        vector_query: "shoe_description_embedding:([], id: 9999)",
        exclude_fields: "shoe_description_embedding"
      }
    ]

    # Errors are returned per-search and must be extracted separately
    error = "Document id referenced in vector query is not found."

    assert {:ok, %MultiSearchResult{results: [%{code: 400, error: ^error}]}} =
             ExTypesense.multi_search(searches)
  end

  @tag ["27.1": true, "27.0": true, "26.0": true]
  test "error: search with non-existent collection" do
    params = [q: "duck", query_by: "name"]

    message = "Not found."

    assert {:error, %ApiResponse{message: ^message}} = ExTypesense.search("test", params)
    assert {:error, %ApiResponse{message: ^message}} = ExTypesense.search_ecto("test", params)

    defmodule Test do
      use Ecto.Schema
      @behaviour ExTypesense

      @moduledoc false

      defimpl Jason.Encoder, for: __MODULE__ do
        def encode(value, opts) do
          value
          |> Map.take([:tests_id, :name])
          |> Enum.map(fn {key, val} ->
            if key === :tests_id, do: {key, Map.get(value, :id)}, else: {key, val}
          end)
          |> Enum.into(%{})
          |> Jason.Encode.map(opts)
        end
      end

      schema "tests" do
        field(:name, :string)
        field(:tests_id, :integer, virtual: true)
      end

      @impl ExTypesense
      def get_field_types do
        name = __MODULE__.__schema__(:source)
        primary_field = name <> "_id"

        %{
          name: name,
          default_sorting_field: primary_field,
          fields: [
            %{name: primary_field, type: "int32"},
            %{name: "name", type: "string"}
          ]
        }
      end
    end

    searches = [
      %{collection: Test, q: "duck", query_by: "name"},
      %{"collection" => "test", "q" => "umbrella", "query_by" => "name"}
    ]

    assert {:ok,
            %MultiSearchResult{
              results: [%{error: "Not found.", code: 404}, %{error: "Not found.", code: 404}]
            }} =
             ExTypesense.multi_search(searches)

    assert [%ApiResponse{message: "Not found."}, %ApiResponse{message: "Not found."}] =
             ExTypesense.multi_search_ecto(searches)
  end
end
