defmodule HexcallWeb.HiveLive.Show do
  use HexcallWeb, :live_view

  alias Hexcall.Hives

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:hive, Hives.get_hive!(id))}
  end

  defp page_title(:show), do: "Show Hive"
  defp page_title(:edit), do: "Edit Hive"
end
