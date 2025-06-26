defmodule Hexcall.Pipelines.CallSink do
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
  def handle_init(_ctx, opts) do
    {[], %{hivename: opts.hivename, position: opts.position}}
  end

  @impl true
  def handle_buffer(:input, buffer, _ctx, state) do
    HexcallWeb.Endpoint.broadcast("audio:#{state.hivename}:#{state.position}", "buffer", buffer)

    {[], state}
  end

  @impl true
  def handle_parent_notification({:update_position, new_position}, _context, state) do
    {[], state |> Map.put(:position, new_position)}
  end
end
