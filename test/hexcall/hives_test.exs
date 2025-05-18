defmodule Hexcall.HivesTest do
  use Hexcall.DataCase

  alias Hexcall.Hives

  describe "hives" do
    alias Hexcall.Hives.Hive

    import Hexcall.HivesFixtures

    @invalid_attrs %{name: nil, size_x: nil, size_y: nil}

    test "list_hives/0 returns all hives" do
      hive = hive_fixture()
      assert Hives.list_hives() == [hive]
    end

    test "get_hive!/1 returns the hive with given id" do
      hive = hive_fixture()
      assert Hives.get_hive!(hive.id) == hive
    end

    test "create_hive/1 with valid data creates a hive" do
      valid_attrs = %{name: "some name", size_x: 42, size_y: 42}

      assert {:ok, %Hive{} = hive} = Hives.create_hive(valid_attrs)
      assert hive.name == "some name"
      assert hive.size_x == 42
      assert hive.size_y == 42
    end

    test "create_hive/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Hives.create_hive(@invalid_attrs)
    end

    test "update_hive/2 with valid data updates the hive" do
      hive = hive_fixture()
      update_attrs = %{name: "some updated name", size_x: 43, size_y: 43}

      assert {:ok, %Hive{} = hive} = Hives.update_hive(hive, update_attrs)
      assert hive.name == "some updated name"
      assert hive.size_x == 43
      assert hive.size_y == 43
    end

    test "update_hive/2 with invalid data returns error changeset" do
      hive = hive_fixture()
      assert {:error, %Ecto.Changeset{}} = Hives.update_hive(hive, @invalid_attrs)
      assert hive == Hives.get_hive!(hive.id)
    end

    test "delete_hive/1 deletes the hive" do
      hive = hive_fixture()
      assert {:ok, %Hive{}} = Hives.delete_hive(hive)
      assert_raise Ecto.NoResultsError, fn -> Hives.get_hive!(hive.id) end
    end

    test "change_hive/1 returns a hive changeset" do
      hive = hive_fixture()
      assert %Ecto.Changeset{} = Hives.change_hive(hive)
    end
  end
end
