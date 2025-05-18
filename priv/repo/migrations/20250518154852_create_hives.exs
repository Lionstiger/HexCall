defmodule Hexcall.Repo.Migrations.CreateHives do
  use Ecto.Migration

  def change do
    create table(:hives, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :size_x, :integer
      add :size_y, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
