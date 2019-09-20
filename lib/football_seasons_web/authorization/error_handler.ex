defmodule FootballSeasons.Authorization.ErrorHandler do
  @moduledoc false

  alias FootballSeasonsWeb.Router.Helpers
  import Plug.Conn
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]

  def auth_error(conn, {_type, _reason}, _opts) do
    conn
    |> put_flash(:info, "You must log in")
    |> redirect(to: Helpers.session_path(conn, :new))
  end
end
