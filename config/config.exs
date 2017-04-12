# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :ops_api, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:ops_api, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#
# Or read environment variables in runtime (!) as:
#
#     :var_name, "${ENV_VAR_NAME}"
config :ops_api,
  ecto_repos: [OPS.Repo]

# Configure your database
config :ops_api, OPS.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: {:system, "DB_NAME", "ops_api_dev"},
  username: {:system, "DB_USER", "postgres"},
  password: {:system, "DB_PASSWORD", "postgres"},
  hostname: {:system, "DB_HOST", "localhost"},
  port: {:system, :integer, "DB_PORT", 5432}
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration

config :ops_api,
  namespace: OPS

# Configures the endpoint
config :ops_api, OPS.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "4LcL78vtzM1yVeVCuY1351HuU/62qpTtDKykdJxAKKgwnTtH5JzkXNEUouzDBc1D",
  render_errors: [view: EView.Views.PhoenixError, accepts: ~w(json)]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configure JSON Logger back-end
config :logger_json, :backend,
  on_init: {OPS, :load_from_system_env, []},
  json_encoder: Poison,
  metadata: :all

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
import_config "#{Mix.env}.exs"
