use Mix.Config

config :logger,
  backends: [:console],
  compile_time_purge_level: :debug

# config :fusion_auth,
#   test_url: System.get_env("FUSION_AUTH_TEST_URL"),
#   api_key: System.get_env("FUSION_AUTH_API_KEY"),
#   tenant_id: System.get_env("FUSION_AUTH_TENANT_ID"),
#   application_id: System.get_env("FUSION_AUTH_APPLICATION_ID"),
#   enable_jwt: true,
#   token_header_key: "authorization",
#   refresh_header_key: "refresh"

# config :fusion_auth, ecto_repos: [FusionAuth.Repo]

# config :fusion_auth, FusionAuth.Repo,
#   username: System.get_env("FUSIONAUTH_DATABASE_USERNAME"),
#   password: System.get_env("FUSIONAUTH_DATABASE_PASSWORD"),
#   database: "fusionauth",
#   hostname: "postgres",
#   port: 5432,
#   pool: Ecto.Adapters.SQL.Sandbox
