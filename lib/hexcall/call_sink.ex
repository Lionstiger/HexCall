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
    # IO.puts("Sending Buffer")
    # IO.inspect(buffer.payload)
    check_payload(buffer, state)
    {[], state}
  end

  defp check_payload(buffer, state) do
    silence =
      <<104, 7, 201, 121, 200, 201, 87, 192, 162, 18, 35, 250, 89, 158, 83, 159, 13, 157, 167,
        158, 236, 186, 56, 202, 182, 217, 184, 160, 243, 96, 243, 64>>

    silence2 =
      <<120, 7, 201, 121, 200, 201, 87, 192, 162, 18, 35, 250, 239, 103, 243, 46, 227, 211, 213,
        233, 236, 219, 62, 188, 128, 182, 110, 42, 183, 140, 131, 205, 131, 205, 0>>

    # if buffer.payload == silence3 do
    # IO.puts "Silence!"
    # else
    # IO.puts "Not Silence"
    IO.inspect(buffer)
    send(state.receiver, {:message, self(), buffer.payload})
    # end
  end
end
