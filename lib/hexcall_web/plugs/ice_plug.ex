defmodule Hexcall.Plugs.ICE_Config do
  @moduledoc """
  A plug to assign the PeerConnection configuration to the connection.
  """
  import Plug.Conn
  require Logger

  def init(opts), do: opts
  # Cant load ICE Config here, because this is compile time land.

  def call(conn, _opts) do
    ice_config = Application.get_env(:hexcall, Hexcall.Plugs.ICE_Config)

    conn
    |> assign(:pc_config, build_pc_config(ice_config))
  end

  defp build_pc_config([{:url, url}, {:username, username}, {:password, password} | _])
       when username not in [nil, ""] and password not in [nil, ""] do
    Jason.encode!(%{
      iceServers: [%{urls: url, username: username, credential: password}],
      iceTransportPolicy: "relay"
    })
  end

  defp build_pc_config([{:url, url} | _]) do
    Jason.encode!(%{iceServers: [%{urls: url}], iceTransportPolicy: "all"})
  end

  defp build_pc_config(%{}) do
    Jason.encode!([%{}])
    Logger.error("No ICE config")
  end
end
