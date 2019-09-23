# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
use Mix.Config

database_url = "ecto://postgres:postgres@localhost/football_seasons_dev"
#  System.get_env("DATABASE_URL") ||
#    raise """
#    environment variable DATABASE_URL is missing.
#    For example: ecto://USER:PASS@HOST/DATABASE
#    """

config :football_seasons, FootballSeasons.Repo,
  # ssl: true,
  username: "postgres",
  password: "postgres",
  database: "football_seasons_dev",
  hostname: "localhost",
  pool_size: 20

secret_key_base = "VTV4aa/E4tW6qqoBOGcrh+ECR4zL+8OMa8U0Y69kb10CAD4VDIdNxCrvEqVjr2zR"
#  System.get_env("SECRET_KEY_BASE") ||
#    raise """
#    environment variable SECRET_KEY_BASE is missing.
#    You can generate one by calling: mix phx.gen.secret
#    """

config :football_seasons, FootballSeasonsWeb.Endpoint,
  http: [:inet6, port: String.to_integer(System.get_env("PORT") || "4000")],
  secret_key_base: secret_key_base

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
#     config :football_seasons, FootballSeasonsWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.
