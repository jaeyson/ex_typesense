defmodule ExTypesense.HttpClientTest do
  use ExUnit.Case, async: true

  alias ExTypesense.HttpClient

  setup do
    # Backup the original configuration
    original_config = Application.get_env(:ex_typesense, :options, %{})

    on_exit(fn ->
      # Restore the original configuration after each test
      Application.put_env(:ex_typesense, :options, original_config)
    end)
  end

  describe "get_options/0" do
    test "returns the configured options" do
      Application.put_env(:ex_typesense, :options, %{
        finch: MyApp.CustomFinch,
        receive_timeout: 5000
      })

      assert HttpClient.get_options() == %{finch: MyApp.CustomFinch, receive_timeout: 5000}
    end

    test "returns an empty map if options is not configured" do
      Application.delete_env(:ex_typesense, :options)

      assert HttpClient.get_options() == %{}
    end
  end
end
