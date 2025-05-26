defmodule Hexcall.Repo.Migrations.AddHivesHexesIndex do
  use Ecto.Migration

  def change do
    create index(:hexes, [:hive_id])
  end
end
