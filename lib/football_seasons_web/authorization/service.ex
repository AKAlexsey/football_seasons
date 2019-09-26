defmodule FootballSeasons.Authorization.Service do
  @moduledoc """
  Contains logic for performing authorization
  """

  alias FootballSeasons.Repo
  alias FootballSeasons.Users.User

  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

  @spec authorize(email :: binary, password :: binary) :: {:ok}
  def authorize(email, password) do
    user = Repo.get_by(User, email: email)

    cond do
      user && checkpw(password, user.password_hash) ->
        {:ok, user}

      user ->
        {:error, :unauthorized}

      true ->
        dummy_checkpw()
        {:error, :not_found}
    end
  end
end
