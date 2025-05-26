defmodule Hexcall.Hives.Hive do
  use Ecto.Schema
  import Ecto.Changeset
  alias Hexcall.Hives.Hex

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "hives" do
    # TODO: either make name unique or access by uuid
    field :name, :string
    field :size_x, :integer
    field :size_y, :integer

    has_many :hexes, Hex

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(hive, attrs) do
    hive
    |> cast(attrs, [:name, :size_x, :size_y])
    |> validate_inclusion(:size_x, 3..30)
    |> validate_inclusion(:size_y, 3..30)
    |> validate_required([:name, :size_x, :size_y])
  end
end
