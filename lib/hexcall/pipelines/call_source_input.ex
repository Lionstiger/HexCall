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
  @doc """
  Initializes the source input by subscribing to the specified Phoenix channel topic.

  ## Parameters
  - `_ctx`: Context information (unused)
  - `opts`: Options map containing `:source_topic` key

  ## Returns
  - Empty actions list
  - State map with empty buffered list and source topic
  """
  def handle_init(_ctx, opts) do
    HexcallWeb.Endpoint.subscribe(opts.source_topic)
    {[], %{buffered: [], source_topic: opts.source_topic}}
  end

  @impl true
  @doc """
  Handles the setup phase of the pipeline.

  ## Parameters
  - `_ctx`: Context information (unused)
  - `state`: Current module state

  ## Returns
  - Empty actions list
  - Unmodified state
  """
  def handle_setup(_ctx, state) do
    # send(self(), Membrane.Opus.Util)
    # IO.inspect(System.os_time(), label: "after: ")
    {[], state}
  end

  @impl true
  @doc """
  Handles the playing state by sending buffered audio and setting stream format.

  When the pipeline enters playing state, this function sends any buffered audio
  and establishes the output stream format as Opus packetized audio.

  ## Parameters
  - `_ctx`: Context information (unused)
  - `state`: Current module state containing buffered audio

  ## Returns
  - Stream format specification for Opus packetized output
  - Buffer sending actions
  - Updated state
  """
  def handle_playing(_ctx, state) do
    {actions, state} = send_buffers(state)

    {[
       stream_format:
         {:output, %Membrane.RemoteStream{content_format: Membrane.Opus, type: :packetized}}
     ] ++
       actions, state}
  end

  @impl true
  @doc """
  Handles incoming buffer messages from Phoenix channels.

  Adds received payload to the buffered list and sends buffers if pipeline is in playing state.

  ## Parameters
  - `%{event: "buffer", payload: payload}`: Message containing audio buffer payload
  - `ctx`: Context with playback state information
  - `state`: Current module state

  ## Returns
  - Buffer actions if in playing state
  - Updated state with new payload added to buffer
  """
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
  @doc """
  Handles unknown messages by logging a warning.

  ## Parameters
  - `msg`: Unknown message payload
  - `_ctx`: Context information (unused)
  - `state`: Current module state

  ## Returns
  - Empty actions list
  - Unmodified state
  """
  def handle_info(msg, _ctx, state) do
    Membrane.Logger.warning("Unknown message received: #{inspect(msg)}")
    {[], state}
  end

  @impl true
  @doc """
  Handles termination request by unsubscribing from the source topic channel.

  ## Parameters
  - `_context`: Context information (unused)
  - `state`: Current module state containing source topic

  ## Returns
  - Terminate action with normal status
  - Unmodified state
  """
  def handle_terminate_request(_context, state) do
    # TODO check if this is actually needed or default behaviour handles this already
    HexcallWeb.Endpoint.unsubscribe(state.source_topic)
    {[{:terminate, :normal}], state}
  end

  @doc """
  Sends all buffered audio messages as buffer actions.

  ## Parameters
  - `state`: Current module state containing buffered messages

  ## Returns
  - List of buffer actions for each message
  - State with cleared buffer list
  """
  defp send_buffers(state) do
    actions =
      Enum.map(state.buffered, fn message ->
        {:buffer, {:output, message}}
      end)

    {actions, %{state | buffered: []}}
  end
end
