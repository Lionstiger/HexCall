defmodule Hexcall.Pipelines.CallSink do
  @moduledoc """
  Membrane sink module for broadcasting audio to WebRTC connections.

  This module receives audio buffers from the pipeline and broadcasts them
  to a specific hive topic. It supports dynamic position updates to change
  the broadcast destination based on notifications from parent components.
  """

  use Membrane.Sink

  def_input_pad(:input,
    flow_control: :auto,
    accepted_format: _any
  )

  def_options(
    hivename: [
      description: "Name of the Hive we send buffers to",
      spec: String.t()
    ],
    position: [
      description: "Current Position to send buffers to",
      spec: HexPos
    ]
  )

  @impl true
  @doc """
  Initializes the call sink with hive name and position options.

  Sets up initial state with hivename and position for later use in channel broadcasting.

  ## Parameters
  - `_ctx`: Context information (unused)
  - `opts`: Options map containing `:hivename` and `:position` keys

  ## Returns
  - Empty actions list
  - State map with hivename and position
  """
  def handle_init(_ctx, opts) do
    {[], %{hivename: opts.hivename, position: opts.position}}
  end

  @impl true
  @doc """
  Handles incoming audio buffers by broadcasting them to the appropriate Phoenix channel.

  ## Parameters
  - `:input`: Input pad identifier
  - `buffer`: Audio buffer to broadcast
  - `_ctx`: Context information (unused)
  - `state`: Current module state containing hivename and position

  ## Returns
  - Empty actions list
  - Unmodified state
  """
  def handle_buffer(:input, buffer, _ctx, state) do
    HexcallWeb.Endpoint.broadcast("audio:#{state.hivename}:#{state.position}", "buffer", buffer)

    {[], state}
  end

  @impl true
  @doc """
  Handles position updates by changing the broadcast target.

  ## Parameters
  - `{:update_position, new_position}`: Tuple containing the new hex position
  - `_context`: Context information (unused)
  - `state`: Current module state containing hivename and current position

  ## Returns
  - Empty actions list
  - Updated state with new position
  """
  def handle_parent_notification({:update_position, new_position}, _context, state) do
    {[], state |> Map.put(:position, new_position)}
  end
end
