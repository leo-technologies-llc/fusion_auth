use Mix.Config

# config :fusion_auth, :tesla, adapter: Tesla.Mock

config :logger,
  backends: [:console],
  compile_time_purge_level: :debug

config :fusion_auth,
  test_url: System.get_env("FUSION_AUTH_TEST_URL"),
  api_url: System.get_env("FUSION_AUTH_URL"),
  api_key: System.get_env("FUSION_AUTH_API_KEY"),
  tenant_id: System.get_env("FUSION_AUTH_TENANT_ID"),
  application_id: System.get_env("FUSION_AUTH_APPLICATION_ID"),
  enable_jwt: true,
  token_header_key: "authorization",
  refresh_header_key: "refresh"
