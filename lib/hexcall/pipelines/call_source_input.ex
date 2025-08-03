defmodule Hexcall.Pipelines.CallSourceInput do
  @moduledoc """
  Membrane source module for receiving audio buffers from Phoenix channels.

  This module subscribes to a specific Phoenix channel topic to receive audio buffers,
  which are then forwarded to the pipeline for processing. It handles the subscription
  lifecycle and buffer queuing for audio data received over WebRTC connections.
  """

  use Membrane.Source

  def_output_pad(:output,
    flow_control: :push,
    accepted_format: _any
  )

  def_options(
    source_topic: [
      description: "The topic we are subscribing to for buffers",
      spec: String.t()
    ]
  )

  @impl true
  def handle_init(_ctx, opts) do
    HexcallWeb.Endpoint.subscribe(opts.source_topic)
    {[], %{buffered: [], source_topic: opts.source_topic}}
  end

  @impl true
  def handle_setup(_ctx, state) do
    # send(self(), Membrane.Opus.Util)
    # IO.inspect(System.os_time(), label: "after: ")
    {[], state}
  end

  @impl true
  def handle_playing(_ctx, state) do
    {actions, state} = send_buffers(state)

    {[
       stream_format:
         {:output, %Membrane.RemoteStream{content_format: Membrane.Opus, type: :packetized}}
     ] ++
       actions, state}
  end

  @impl true
  def handle_info(%{event: "buffer", payload: payload}, ctx, state) do
    # IO.inspect(payload)
    state = %{state | buffered: state.buffered ++ [payload]}

    if ctx.playback == :playing do
      send_buffers(state)
    else
      {[], state}
    end
  end

  @impl true
  def handle_info(msg, _ctx, state) do
    Membrane.Logger.warning("Unknown message received: #{inspect(msg)}")
    {[], state}
  end

  @impl true
  def handle_terminate_request(_context, state) do
    # TODO check if this is actually needed or default behaviour handles this already
    HexcallWeb.Endpoint.unsubscribe(state.source_topic)
    {[{:terminate, :normal}], state}
  end

  defp send_buffers(state) do
    actions =
      Enum.map(state.buffered, fn message ->
        {:buffer, {:output, message}}
      end)

    {actions, %{state | buffered: []}}
  end
end
