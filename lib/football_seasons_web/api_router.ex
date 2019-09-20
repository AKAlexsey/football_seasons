defmodule FootballSeasonsWeb.ApiRouter do
  @moduledoc """
  Handle API requests.
  """

  alias FootballSeasons.Caching.SearchSeasons
  alias FootballSeasons.Seasons
  use Plug.Router

  plug(Plug.Logger, log: :debug)
  plug(:fetch_query_params)
  plug(:match)
  plug(:dispatch)

  get "/api/seasons" do
    {response_conn, status, body} = SearchSeasons.make_index_response(conn)
    send_resp(response_conn, status, body)
  end

  # This callback added to compare velocity between requests to cache and database
  # In fact most time spent in Jason.encode!() anyway in Mnesia we have cached JSON view
  get "/api/db_seasons" do
    games =
      Seasons.list_games()
      |> prepare_database_games()

    send_resp(conn, 200, games)
  end

  get "/api/seasons/search" do
    {response_conn, status, body} = SearchSeasons.make_search_response(conn)
    send_resp(response_conn, status, body)
  end

  # Also added for comparison with cached version
  get "/api/db_seasons/search" do
    games =
      conn
      |> fetch_params()
      |> Seasons.search_games()
      |> prepare_database_games()

    send_resp(conn, 200, games)
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end

  defp fetch_params(%Plug.Conn{query_params: query_params}) do
    {
      Map.get(query_params, "division", nil),
      Map.get(query_params, "season", nil)
    }
  end

  defp prepare_database_games(games) do
    games
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
  end
end
