defmodule FootballSeasons.Authorization.Pipeline do
  @moduledoc false

  use Guardian.Plug.Pipeline,
    otp_app: :football_seasons,
    error_handler: FootballSeasons.Authorization.ErrorHandler,
    module: FootballSeasons.Authorization.Guardian

  plug(Guardian.Plug.VerifySession, claims: %{"typ" => "access"})

  plug(Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"})

  plug(Guardian.Plug.LoadResource, allow_blank: true)
end
