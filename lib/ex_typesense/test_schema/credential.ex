defmodule ExTypesense.TestSchema.Credential do
  use Ecto.Schema

  @moduledoc false

  schema "credentials" do
    field(:node, :string)
    field(:secret_key, :string)
    field(:port, :integer)
    field(:scheme, :string)
  end
end
