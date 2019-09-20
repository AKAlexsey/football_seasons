defmodule FootballSeasonsWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      import FootballSeasons.Factory
      alias FootballSeasons.Authorization.Guardian, as: GuardianImplementation
      import FootballSeasonsWeb.Router.Helpers
      alias Guardian.Plug, as: GuardianPlug
      import Plug.Conn

      # The default endpoint for testing
      @endpoint FootballSeasonsWeb.Endpoint

      def authorize_user(%{conn: conn, user: user}) do
        {:ok, conn: login_user(conn, user)}
      end

      def authorize_user(%{conn: conn}) do
        user = insert(:user)
        {:ok, conn: login_user(conn, user)}
      end

      defp login_user(conn, user) do
        GuardianPlug.sign_in(conn, GuardianImplementation, user)
      end
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(FootballSeasons.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(FootballSeasons.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
