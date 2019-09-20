defmodule FootballSeasons.Authorization.Guardian do
  @moduledoc false

  use Guardian, otp_app: :football_seasons

  alias FootballSeasons.Repo
  alias FootballSeasons.Users.User

  def subject_for_token(%User{} = user, _), do: {:ok, "User:#{user.id}"}
  def subject_for_token(_, _), do: {:error, "Unknown resource type"}

  def subject_from_token("User:" <> id, _), do: {:ok, Repo.get(User, id)}
  def subject_from_token(_, _), do: {:error, "Unknown resource type"}

  def resource_from_claims(claims) do
    with {:ok, user_id} <- user_from_claims(claims),
         {:ok, user} <- safe_get_user(user_id) do
      {:ok, user}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp user_from_claims(claims) do
    case claims["sub"] do
      "User:" <> user_id -> {:ok, user_id}
      _ -> {:error, :unauthorized}
    end
  end

  defp safe_get_user(user_id) do
    case Repo.get(User, user_id) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end
end
