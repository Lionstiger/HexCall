defmodule Hexcall.Hives.Hex do
  use Ecto.Schema
  import Ecto.Changeset
  alias Hexcall.Hives.Hive

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "hexes" do
    field :q, :integer
    field :r, :integer
    field :s, :integer, virtual: true
    field :type, Ecto.Enum, values: [:basic, :group, :meeting, :disabled]

    belongs_to :hive, Hive

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(hex, attrs) do
    hex
    |> cast(attrs, [:q, :r, :s, :type, :hive_id])
    # |> cast_assoc(:hive, Hive) # This seems like overkill
    # |> validate_zero_sum()
    |> validate_required([:q, :r, :s, :type, :hive_id])
  end

  @doc """
  Changeset calculation
  """
  defp validate_zero_sum(changeset) do
    q = get_field(changeset, :q)
    r = get_field(changeset, :r)
    s = get_field(changeset, :s)

    if r + q + s == 0 do
      changeset
    else
      changeset
      |> add_error([:s, :r, :q], "Invalid Coordinates, Sum must be 0.")
    end
  end
end
