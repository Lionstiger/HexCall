defmodule HexcallWeb.CallLive do
  use HexcallWeb, :live_view
  require Logger

  alias Membrane.WebRTC.Live.{Capture, Player}

  @impl true
  def mount(%{"room" => room}, _session, socket) do
    socket =
      if connected?(socket) do
        ingress_signaling = Membrane.WebRTC.Signaling.new()
        egress_signaling = Membrane.WebRTC.Signaling.new()

        Membrane.Pipeline.start_link(Hexcall.CallPipeline,
          ingress_signaling: ingress_signaling,
          egress_signaling: egress_signaling,
          roomname: room
        )

        socket
        |> Capture.attach(
          id: "mediaCapture",
          signaling: ingress_signaling,
          video?: false,
          audio?: true,
          preview?: false
        )
        |> Player.attach(
          id: "audioPlayer",
          signaling: egress_signaling
        )
      else
        socket
      end

    {:ok, socket}
  end

  # @impl true
  # def handle_event("webrtc_signaling", data, _socket) do
  #   IO.inspect(data)
  # end

  # TODO: Setup receiving streams from other. Somehow merge all incoming audio into single output
  # TODO: Push this stream back down to client via webrtc

  # TODO: Send Position updates to RoomManager
end
