defmodule HexcallWeb.PageController do
  use HexcallWeb, :controller

  def home(conn, _params) do
    conn =
      conn
      |> assign(:current_user, nil)

    render(conn, :home, layout: false)
  end
end
