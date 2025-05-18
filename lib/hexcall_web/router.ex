defmodule HexcallWeb.Router do
  alias HexcallWeb.HiveLive
  use HexcallWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HexcallWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HexcallWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/hive", HexcallWeb do
    pipe_through :browser

    # live "/", CallLive
    live "/:hive", CallLive
  end

  scope "/admin" do
    pipe_through :browser

    # live_session :hives do
    live "/hives", HiveLive.Index, :index
    live "/hives/new", HiveLive.Index, :new
    live "/hives/:id/edit", HiveLive.Index, :edit

    live "/hives/:id", HiveLive.Show, :show
    live "/hives/:id/show/edit", HiveLive.Show, :edit
    # end
  end

  # Other scopes may use custom stacks.
  # scope "/api", HexcallWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:hexcall, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: HexcallWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
