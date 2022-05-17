defmodule FusionAuth.Repo do
  use Ecto.Repo,
    otp_app: :fusion_auth,
    adapter: Ecto.Adapters.Postgres
end
