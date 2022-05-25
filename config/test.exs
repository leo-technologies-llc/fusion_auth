import Config

config :logger, level: :error

config :fusion_auth,
  api_url: System.get_env("FUSION_AUTH_TEST_URL"),
  api_key: System.get_env("FUSION_AUTH_API_KEY"),
  tenant_id: System.get_env("FUSION_AUTH_TENANT_ID"),
  application_id: System.get_env("FUSION_AUTH_APPLICATION_ID"),
  enable_jwt: true,
  token_header_key: "authorization",
  refresh_header_key: "refresh"
