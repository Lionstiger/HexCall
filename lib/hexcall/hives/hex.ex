defmodule Hexcall.Hives.Hex do
  use Ecto.Schema
  import Ecto.Changeset
  alias Hexcall.Hives.Hive

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "hexes" do
    field :q, :integer
    field :r, :integer
    field :type, Ecto.Enum, values: [:basic, :group, :meeting, :disabled]

    belongs_to :hive, Hive

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(hex, attrs) do
    hex
    |> cast(attrs, [:q, :r, :type])
    |> validate_required([:q, :r, :type])
  end
end
