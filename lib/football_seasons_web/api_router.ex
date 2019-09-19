defmodule FootballSeasonsWeb.ApiRouter do
  @moduledoc """
  Handle API requests.
  """

  alias FootballSeasons.Caching.SearchSeasons
  use Plug.Router

  plug(Plug.Logger, log: :debug)
  plug(:fetch_query_params)
  plug(:match)
  plug(:dispatch)

  get "/api/seasons" do
    {response_conn, status, body} = SearchSeasons.make_index_response(conn)
    send_resp(response_conn, status, body)
  end

  alias FootballSeasons.Seasons

  get "/api/db_seasons" do
    games =
      Seasons.list_games()
      |> Enum.map(fn game ->
        game
        |> Map.delete(:__struct__)
        |> Map.delete(:__meta__)
        |> Map.delete(:home_team)
        |> Map.delete(:away_team)
        |> Map.delete(:id)
        |> Map.delete(:inserted_at)
        |> Map.delete(:updated_at)
      end)
      |> Jason.encode!()

    send_resp(conn, 200, games)
  end

  get "/api/seasons/search" do
    {response_conn, status, body} = SearchSeasons.make_search_response(conn)
    send_resp(response_conn, status, body)
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
