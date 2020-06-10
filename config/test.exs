use Mix.Config

config :fusion_auth, :tesla, adapter: Tesla.Mock

config :fusion_auth,
  api_key: System.get_env("FUSION_AUTH_API_KEY"),
  api_url: System.get_env("FUSION_AUTH_URL"),
  tenant_id: System.get_env("FUSION_AUTH_TENANT_ID"),
  application_id: System.get_env("FUSION_AUTH_APPLICATION_ID"),
  enable_jwt: true,
  jwt_header_key: "authorization",
  enable_access_roles: false,
  access_roles: ["admin", "user"]
