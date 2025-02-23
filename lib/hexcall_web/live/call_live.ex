defmodule HexcallWeb.CallLive do
  use HexcallWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    # if connected?(socket) do
    # TODO: setup webrtc connection (both ways) here
    # TODO: sign up to room position topic
    # else
      {:ok, socket}
    # end
  end

  # TODO: setup pipeline to parse uploaded audio

  # TODO: Setup receiving streams from other. Somehow merge all incoming audio into single output
  # TODO: Push this stream back down to client via webrtc

  # TODO: Use pubsub to handle who audio is send to and who audio is received from

  # TODO: Send Position updates to RoomManager

  @impl true
  def render(assigns) do
    ~H"""
    <div class="call-container">
      <div id="audio-controls" phx-hook="AudioCall" class="p-4">
        <button id="toggle-audio" class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600">
          Start Microphone
        </button>
        <div class="mt-2 text-sm text-gray-600">
          Click the button above to start/stop your microphone
        </div>
      </div>
    </div>
    """
  end
end
