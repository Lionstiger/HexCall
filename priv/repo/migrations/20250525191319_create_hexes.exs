defmodule Hexcall.Repo.Migrations.CreateHexes do
  use Ecto.Migration

  def change do
    create table(:hexes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :q, :integer
      add :r, :integer
      add :type, :string
      add :hive_id, references(:hives, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:hexes, [:hive_id, :q, :r])
  end
end
