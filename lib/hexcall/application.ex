defmodule Hexcall.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      HexcallWeb.Telemetry,
      Hexcall.Repo,
      {DNSCluster, query: Application.get_env(:hexcall, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Hexcall.PubSub},
      {PartitionSupervisor, child_spec: DynamicSupervisor, name: Hexcall.DynamicSupervisors},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Hexcall.Finch},
      # Start a worker by calling: Hexcall.Worker.start_link(arg)
      # {Hexcall.Worker, arg},
      # Start to serve requests, typically the last entry
      HexcallWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Hexcall.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HexcallWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
