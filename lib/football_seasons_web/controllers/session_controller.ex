defmodule FootballSeasonsWeb.SessionController do
  use FootballSeasonsWeb, :controller

  alias FootballSeasons.Authorization.Guardian, as: GuardianImplementation
  alias FootballSeasons.Users
  alias Guardian.Plug, as: GuardianPlug

  import Bcrypt, only: [verify_pass: 2, no_user_verify: 0]

  plug :scrub_params, "session" when action in ~w(create)a

  def new(conn, _) do
    render(conn, "new.html")
  end

  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    user = Users.user_by_email(email)

    result =
      cond do
        user && verify_pass(password, user.password_hash) ->
          {:ok, login(conn, user)}

        user ->
          {:error, :unauthorized, conn}

        true ->
          no_user_verify()
          {:error, :not_found, conn}
      end

    case result do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "You’re now logged in!")
        |> redirect(to: page_path(conn, :index))

      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Invalid email/password combination")
        |> render("new.html")
    end
  end

  defp login(conn, user) do
    GuardianPlug.sign_in(conn, GuardianImplementation, user)
  end

  def delete(conn, _) do
    conn
    |> logout()
    |> put_flash(:info, "You have logged out!")
    |> redirect(to: page_path(conn, :index))
  end

  defp logout(conn) do
    Guardian.Plug.sign_out(conn, GuardianImplementation, [])
  end
end
