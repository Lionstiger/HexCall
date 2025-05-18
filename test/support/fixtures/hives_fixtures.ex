defmodule Hexcall.HivesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Hexcall.Hives` context.
  """

  @doc """
  Generate a hive.
  """
  def hive_fixture(attrs \\ %{}) do
    {:ok, hive} =
      attrs
      |> Enum.into(%{
        name: "some name",
        size_x: 42,
        size_y: 42
      })
      |> Hexcall.Hives.create_hive()

    hive
  end
end
