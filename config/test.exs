use Mix.Config

# config :logger,
#   backends: [:console],
#   compile_time_purge_level: :debug

config :logger, level: :error

config :fusion_auth,
  test_url: System.get_env("FUSION_AUTH_TEST_URL"),
  api_key: System.get_env("FUSION_AUTH_API_KEY"),
  tenant_id: System.get_env("FUSION_AUTH_TENANT_ID"),
  application_id: System.get_env("FUSION_AUTH_APPLICATION_ID"),
  enable_jwt: true,
  token_header_key: "authorization",
  refresh_header_key: "refresh"

config :fusion_auth, ecto_repos: [FusionAuth.Repo]

config :fusion_auth, FusionAuth.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "fusionauth",
  password: "hkaLBM3RVnyYeYeqE3WI1w2e4Avpy0Wd5O3s3",
  database: "fusionauth",
  hostname: "172.30.243.114",
  port: 25432,
  pool: Ecto.Adapters.SQL.Sandbox
