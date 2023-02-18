# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :football_seasons,
  ecto_repos: [FootballSeasons.Repo]

# Configures the endpoint
config :football_seasons, FootballSeasonsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "DROG3oubXLCS+r17jl5m6fJ7HucMcwnPP+t5Xzjsc87xaFwXvik4ImRRm7semQaF",
  render_errors: [view: FootballSeasonsWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: FootballSeasons.PubSub

config :football_seasons, :plug_configuration,
  # Api port
  api_port: 4001,
  # Restrict upload file size
  maximum_upload_size: 10_485_760,
  # Path to *.proto file where described games schema
  proto_path: "./priv/protobuf/game.proto"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Mnesia configurations
config :mnesia,
  dir: '.mnesia/#{Mix.env()}/#{node()}'

config :football_seasons, FootballSeasons.Authorization.Guardian,
  issuer: "SimpleAuth",
  secret_key: "U7fWw3uDlga9DRB"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
