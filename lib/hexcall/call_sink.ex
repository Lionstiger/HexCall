defmodule Hexcall.CallSink do
  use Membrane.Sink

  def_input_pad(:input,
    flow_control: :auto,
    accepted_format: _any
  )

  def_options(
    roomname: [
      description: "Name of the Room we send buffers to",
      spec: String.t()
    ]
  )

  @impl true
  def handle_init(_ctx, opts) do
    {[], %{roomname: opts.roomname}}
  end

  @impl true
  def handle_buffer(:input, buffer, _ctx, state) do
    HexcallWeb.Endpoint.broadcast(state.roomname, "buffer", buffer)
    {[], state}
  end
end
