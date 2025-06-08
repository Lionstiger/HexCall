defmodule HexcallWeb.CallLive do
  use HexcallWeb, :live_view
  require Logger

  # alias Membrane.WebRTC.Live.{Capture, Player}
  alias HexcallWeb.Components.{Capture, Player, HexCell}
  alias Hexcall.Hives
  alias Hexcall.HiveManager

  @impl true
  def mount(%{"hive" => hivename}, _session, socket) do
    hive = Hives.get_hive_by_name_with_hexes(hivename)

    hive_manager = HiveManager.start(hivename)
    # This needs to be replaced when Auth is added
    user_id = Ecto.UUID.generate()

    if is_nil(hive) do
      {:ok, redirect(socket, to: "/")}
    else
      socket =
        if connected?(socket) do
          ingress_signaling = Membrane.WebRTC.Signaling.new()
          egress_signaling = Membrane.WebRTC.Signaling.new()

          Membrane.Pipeline.start_link(Hexcall.CallPipeline,
            ingress_signaling: ingress_signaling,
            egress_signaling: egress_signaling,
            hivename: hivename
          )

          socket
          |> Capture.attach(
            id: "mediaCapture",
            signaling: ingress_signaling
          )
          |> Player.attach(
            id: "audioPlayer",
            signaling: egress_signaling
          )
        else
          socket
        end

      {:ok,
       socket
       |> assign(:hive, hive)
       |> assign(:hive_manager, hive_manager)
       |> assign(:user_id, user_id), layout: false}
    end
  end

  @impl true
  def handle_event("click", data, socket) do
    hive_manager = socket.assigns.hive_manager
    user_id = socket.assigns.user_id
    IO.inspect(HiveManager.move(hive_manager, user_id, data))
    IO.inspect(HiveManager.get_state(hive_manager))
    {:noreply, socket}
  end

  @impl true
  def terminate(_reason, socket) do
    hive_manager = socket.assigns.hive_manager
    user_id = socket.assigns.user_id
    HiveManager.leave(hive_manager, user_id)
  end

  # TODO: Setup receiving streams from other. Somehow merge all incoming audio into single output
  # TODO: Push this stream back down to client via webrtc

  # TODO: Send Position updates to RoomManager
end
