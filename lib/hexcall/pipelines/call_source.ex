defmodule Hexcall.Pipelines.CallSource do
  @moduledoc """
  Membrane source module for collecting audio input from WebRTC connections.

  This module receives audio data through WebRTC and forwards it to the pipeline.
  It subscribes to a specific hive topic and can update its listening position
  dynamically based on notifications from parent components.
  """

  alias Hexcall.HexPos
  alias Membrane.Opus
  use Membrane.Source

  require Membrane.Logger

  def_output_pad(:output,
    flow_control: :push,
    accepted_format: _any
  )

  def_options(
    hivename: [
      description: "Name of the Hive we subscribe to, to receive buffers from",
      spec: String.t()
    ],
    position: [
      description: "Current Position to listen at",
      spec: HexPos
    ]
  )

  @impl true
  @doc """
  Initializes the call source with hive name and position options.

  Sets up initial state with empty buffer list and stores the hivename and position
  for later use in channel subscriptions.

  ## Parameters
  - `_ctx`: Context information (unused)
  - `opts`: Options map containing `:hivename` and `:position` keys

  ## Returns
  - Empty actions list
  - State map with buffered list, hivename, and position
  """
  def handle_init(_ctx, opts) do
    # Design funneling multiple input together
    {[], %{buffered: [], hivename: opts.hivename, position: opts.position}}
  end

  @impl true
  @doc """
  Handles the playing state by sending buffered audio data and setting stream format.

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

    {[stream_format: {:output, %Membrane.RemoteStream{content_format: Opus, type: :packetized}}] ++
       actions, state}

    # {[stream_format: {:output, %Membrane.RemoteStream{type: :bytestream}}] ++ actions, state}
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
  Handles termination request by unsubscribing from the hivename channel.

  ## Parameters
  - `_context`: Context information (unused)
  - `state`: Current module state containing hivename

  ## Returns
  - Empty actions list
  - Unmodified state
  """
  def handle_terminate_request(_context, state) do
    HexcallWeb.Endpoint.unsubscribe(state.hivename)
    {[], state}
  end

  @impl true
  @doc """
  Handles position updates by changing channel subscriptions.

  Unsubscribes from the old position channel and subscribes to the new position channel.

  ## Parameters
  - `{:update_position, new_position}`: Tuple containing the new hex position
  - `_context`: Context information (unused)
  - `state`: Current module state containing hivename and current position

  ## Returns
  - Empty actions list
  - Updated state with new position
  """
  def handle_parent_notification({:update_position, new_position}, _context, state) do
    HexcallWeb.Endpoint.unsubscribe("audio:#{state.hivename}:#{state.position}")
    HexcallWeb.Endpoint.subscribe("audio:#{state.hivename}:#{new_position}")
    {[], state |> Map.put(:position, new_position)}
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
