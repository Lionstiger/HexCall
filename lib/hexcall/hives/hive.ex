defmodule Hexcall.Hives.Hive do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "hives" do
    field :name, :string
    field :size_x, :integer
    field :size_y, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(hive, attrs) do
    hive
    |> cast(attrs, [:name, :size_x, :size_y])
    |> validate_required([:name, :size_x, :size_y])
  end
end
