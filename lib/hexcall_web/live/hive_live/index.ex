defmodule HexcallWeb.HiveLive.Index do
  use HexcallWeb, :live_view

  alias Hexcall.Hives
  alias Hexcall.Hives.Hive

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :hives, Hives.list_hives())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Hive")
    |> assign(:hive, Hives.get_hive!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Hive")
    |> assign(:hive, %Hive{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Hives")
    |> assign(:hive, nil)
  end

  @impl true
  def handle_info({HexcallWeb.HiveLive.FormComponent, {:saved, hive}}, socket) do
    {:noreply, stream_insert(socket, :hives, hive)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    hive = Hives.get_hive!(id)
    {:ok, _} = Hives.delete_hive(hive)

    {:noreply, stream_delete(socket, :hives, hive)}
  end
end
