defmodule Hexcall.CallSource do
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
  def handle_init(_ctx, opts) do
    # Design funneling multiple input together
    {[], %{buffered: [], hivename: opts.hivename, position: opts.position}}
  end

  @impl true
  def handle_playing(_ctx, state) do
    {actions, state} = send_buffers(state)

    {[stream_format: {:output, %Membrane.RemoteStream{content_format: Opus, type: :packetized}}] ++
       actions, state}

    # {[stream_format: {:output, %Membrane.RemoteStream{type: :bytestream}}] ++ actions, state}
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
    HexcallWeb.Endpoint.unsubscribe(state.hivename)
    {[], state}
  end

  @impl true
  def handle_parent_notification({:update_position, new_position}, _context, state) do
    HexcallWeb.Endpoint.unsubscribe("audio:#{state.hivename}:#{state.position}")
    HexcallWeb.Endpoint.subscribe("audio:#{state.hivename}:#{new_position}")
    {[], state |> Map.put(:position, new_position)}
  end

  defp send_buffers(state) do
    actions =
      Enum.map(state.buffered, fn message ->
        {:buffer, {:output, message}}
      end)

    {actions, %{state | buffered: []}}
  end
end
