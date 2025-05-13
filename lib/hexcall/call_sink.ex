defmodule Hexcall.CallSink do
  use Membrane.Sink

  def_input_pad(:input,
    flow_control: :auto,
    accepted_format: _any
  )

  def_options(
    receiver: [
      description: "PID of the process that will receive messages from the sink",
      spec: pid()
    ]
  )

  @impl true
  def handle_init(_ctx, opts) do
    {[], %{receiver: opts.receiver}}
  end

  @impl true
  def handle_buffer(:input, buffer, _ctx, state) do
    send(
      state.receiver,
      {:message, self(), buffer}
    )

    {[], state}
  end
end
