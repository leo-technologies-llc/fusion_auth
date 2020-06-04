use Mix.Config

config :fusion_auth,
  api_key: System.get_env("FUSION_AUTH_API_KEY"),
  api_url: System.get_env("FUSION_AUTH_URL"),
  tenant_id: System.get_env("FUSION_AUTH_TENANT_ID")
