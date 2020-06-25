use Mix.Config

config :fusion_auth,
  api_key: System.get_env("FUSION_AUTH_API_KEY"),
  api_url: System.get_env("FUSION_AUTH_URL"),
  tenant_id: System.get_env("FUSION_AUTH_TENANT_ID"),
  application_id: System.get_env("FUSION_AUTH_APPLICATION_ID"),
  enable_jwt: true,
  token_header_key: "authorization",
  refresh_header_key: "refresh",
  enable_access_roles: false,
  access_roles: ["superadmin", "admin", "user"]
