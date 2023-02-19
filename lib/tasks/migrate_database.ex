defmodule FootballSeasons.Tasks.MigrateDatabase do
  @moduledoc "Mix task to run Ecto database migrations"

  # CHANGEME: Name of app as used by Application.get_env
  @app :football_seasons
  # CHANGEME: Name of app repo module
  @repo_module FootballSeasons.Repo

  def run(args \\ [])

  def run(_args) do
    # ext_name = @app |> to_string |> String.replace("_", "-")

    # Start requisite apps
    IO.puts("==> Starting applications..")

    for app <- [:crypto, :ssl, :postgrex, :ecto, :ecto_sql] do
      {:ok, res} = Application.ensure_all_started(app)
      IO.puts("==> Started #{app}: #{inspect(res)}")
    end

    # Start repo
    IO.puts("==> Starting repo")
    apply(@repo_module, :start_link, [[pool_size: 2, log: :info, log_sql: true]])

    # Run migrations for the repo
    IO.puts("==> Running migrations")
    priv_dir = Application.app_dir(@app, "priv")
    migrations_dir = Path.join([priv_dir, "repo", "migrations"])

    opts = [all: true]
    config = apply(@repo_module, :config, [])
    pool = config[:pool]

    if function_exported?(pool, :unboxed_run, 2) do
      pool.unboxed_run(@repo_module, fn ->
        Ecto.Migrator.run(@repo_module, migrations_dir, :up, opts)
      end)
    else
      Ecto.Migrator.run(@repo_module, migrations_dir, :up, opts)
    end
  end
end
