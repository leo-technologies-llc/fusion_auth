# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# third-party users, it should be done in your "mix.exs" file.

# You can configure your application as:

# config :fusion_auth,
#   api_key: "FUSION_AUTH_API_KEY",
#   api_url: "FUSION_AUTH_URL",
#   tenant_id: "FUSION_AUTH_TENANT_ID",
#   application_id: "FUSION_AUTH_APPLICATION_ID",
#   enable_jwt: true,
#   token_header_key: "authorization"
#   refresh_header_key: "refresh"
#   enable_access_roles: false,
#   access_roles: ["superadmin", "admin", "user"]

#
# and access this configuration in your application as:
#
#     Application.get_env(:fusion_auth, :api_key)
#
# You can also configure a third-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).

env_config = "#{Mix.env()}.exs"
File.exists?("config/#{env_config}") && import_config(env_config)
