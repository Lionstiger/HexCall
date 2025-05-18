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
    ]
  )

  @impl true
  def handle_init(_ctx, opts) do
    {[], %{hivename: opts.hivename}}
  end

  @impl true
  def handle_buffer(:input, buffer, _ctx, state) do
    HexcallWeb.Endpoint.broadcast(state.hivename, "buffer", buffer)
    {[], state}
  end
end
