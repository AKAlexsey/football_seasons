defmodule FootballSeasons.MixProject do
  use Mix.Project

  def project do
    [
      app: :football_seasons,
      version: "0.9.0",
      elixir: "~> 1.13.3",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      docs: [
        main: "FootballSeasons",
        extras: ["README.md"]
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {FootballSeasons.Application, []},
      extra_applications: [
        :logger,
        :runtime_tools,
        :memento,
        :plug_cowboy,
        :nimble_csv,
        :comeonin,
        :exprotobuf
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # Framework
      {:phoenix, "~> 1.6.16"},
      {:phoenix_pubsub, "~> 2.1.1"},

      # Database
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.9"},
      {:postgrex, ">= 0.0.0"},
      {:ecto_observable, "~> 0.4"},
      # Caching database for providing high speed searching for seasons
      {:memento, "~> 0.3.1"},

      # Tools
      {:phoenix_html, "~> 3.3"},
      {:phoenix_live_reload, "~> 1.4", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:nimble_csv, "~> 0.3"},
      {:timex, "~> 3.6"},
      {:gpb, "~> 4.0", manager: :rebar3, override: true},
      {:exprotobuf, "~> 1.2.17"},

      # Release
      {:distillery, "~> 1.5"},

      # Authorization
      {:bcrypt_elixir, "~> 0.12"},
      {:comeonin, "~> 4.0"},
      {:guardian, "~> 2.3"},

      # Code quality
      {:credo, "~> 1.1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},

      # Test
      {:ex_machina, "~> 2.3", only: [:test]},
      {:faker, "~> 0.12", only: :test}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
