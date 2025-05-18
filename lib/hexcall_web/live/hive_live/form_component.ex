defmodule HexcallWeb.HiveLive.FormComponent do
  use HexcallWeb, :live_component

  alias Hexcall.Hives

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage hive records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="hive-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:size_x]} type="number" label="Size x" />
        <.input field={@form[:size_y]} type="number" label="Size y" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Hive</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{hive: hive} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Hives.change_hive(hive))
     end)}
  end

  @impl true
  def handle_event("validate", %{"hive" => hive_params}, socket) do
    changeset = Hives.change_hive(socket.assigns.hive, hive_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"hive" => hive_params}, socket) do
    save_hive(socket, socket.assigns.action, hive_params)
  end

  defp save_hive(socket, :edit, hive_params) do
    case Hives.update_hive(socket.assigns.hive, hive_params) do
      {:ok, hive} ->
        notify_parent({:saved, hive})

        {:noreply,
         socket
         |> put_flash(:info, "Hive updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_hive(socket, :new, hive_params) do
    case Hives.create_hive(hive_params) do
      {:ok, hive} ->
        notify_parent({:saved, hive})

        {:noreply,
         socket
         |> put_flash(:info, "Hive created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
