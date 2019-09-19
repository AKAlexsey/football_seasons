defmodule FootballSeasons.Authorization.Service do
  @moduledoc """
  Contains logic for performing authorization
  """

  alias FootballSeasons.Repo
  alias FootballSeasons.Users.User

  import Bcrypt, only: [verify_pass: 2, no_user_verify: 0]

  @spec authorize(email :: binary, password :: binary) :: {:ok}
  def authorize(email, password) do
    user = Repo.get_by(User, email: email)

    cond do
      user && verify_pass(password, user.password_hash) ->
        {:ok, user}

      user ->
        {:error, :unauthorized}

      true ->
        no_user_verify()
        {:error, :not_found}
    end
  end
end
