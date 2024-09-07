defmodule Hexcall.Repo do
  use Ecto.Repo,
    otp_app: :hexcall,
    adapter: Ecto.Adapters.Postgres
end
