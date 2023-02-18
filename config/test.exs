import Config

# Configure your database
config :football_seasons, FootballSeasons.Repo,
  username: "postgres",
  password: "postgres",
  database: "football_seasons_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :football_seasons, FootballSeasonsWeb.Endpoint,
  http: [port: 4002],
  server: false

# Api configuration
config :football_seasons, :plug_configuration, api_port: 4003

# Print only warnings and errors during test
config :logger, level: :warn
