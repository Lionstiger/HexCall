defmodule HexcallWeb.HiveLiveTest do
  use HexcallWeb.ConnCase

  import Phoenix.LiveViewTest
  import Hexcall.HivesFixtures

  @create_attrs %{name: "some name", size_x: 42, size_y: 42}
  @update_attrs %{name: "some updated name", size_x: 43, size_y: 43}
  @invalid_attrs %{name: nil, size_x: nil, size_y: nil}

  defp create_hive(_) do
    hive = hive_fixture()
    %{hive: hive}
  end

  describe "Index" do
    setup [:create_hive]

    test "lists all hives", %{conn: conn, hive: hive} do
      {:ok, _index_live, html} = live(conn, ~p"/hives")

      assert html =~ "Listing Hives"
      assert html =~ hive.name
    end

    test "saves new hive", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/hives")

      assert index_live |> element("a", "New Hive") |> render_click() =~
               "New Hive"

      assert_patch(index_live, ~p"/hives/new")

      assert index_live
             |> form("#hive-form", hive: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#hive-form", hive: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/hives")

      html = render(index_live)
      assert html =~ "Hive created successfully"
      assert html =~ "some name"
    end

    test "updates hive in listing", %{conn: conn, hive: hive} do
      {:ok, index_live, _html} = live(conn, ~p"/hives")

      assert index_live |> element("#hives-#{hive.id} a", "Edit") |> render_click() =~
               "Edit Hive"

      assert_patch(index_live, ~p"/hives/#{hive}/edit")

      assert index_live
             |> form("#hive-form", hive: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#hive-form", hive: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/hives")

      html = render(index_live)
      assert html =~ "Hive updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes hive in listing", %{conn: conn, hive: hive} do
      {:ok, index_live, _html} = live(conn, ~p"/hives")

      assert index_live |> element("#hives-#{hive.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#hives-#{hive.id}")
    end
  end

  describe "Show" do
    setup [:create_hive]

    test "displays hive", %{conn: conn, hive: hive} do
      {:ok, _show_live, html} = live(conn, ~p"/hives/#{hive}")

      assert html =~ "Show Hive"
      assert html =~ hive.name
    end

    test "updates hive within modal", %{conn: conn, hive: hive} do
      {:ok, show_live, _html} = live(conn, ~p"/hives/#{hive}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Hive"

      assert_patch(show_live, ~p"/hives/#{hive}/show/edit")

      assert show_live
             |> form("#hive-form", hive: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#hive-form", hive: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/hives/#{hive}")

      html = render(show_live)
      assert html =~ "Hive updated successfully"
      assert html =~ "some updated name"
    end
  end
end
