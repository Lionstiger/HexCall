defmodule Hexcall.CallSink do
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
    listeners: [
      description: "List of positions to send audio to",
      spec: List.t()
    ]
  )

  @impl true
  def handle_init(_ctx, opts) do
    {[], %{hivename: opts.hivename, listeners: opts.listeners}}
  end

  @impl true
  def handle_buffer(:input, buffer, _ctx, state) do
    # TODO send data to neighbors here, not just to the hive
    for hex <- state.listeners do
      HexcallWeb.Endpoint.broadcast("audio:#{state.hivename}:#{hex}", "buffer", buffer)
    end

    {[], state}
  end

  @impl true
  def handle_parent_notification({:update_listeners, new_listeners}, _context, state) do
    {[], state |> Map.put(:listeners, new_listeners)}
  end
end
