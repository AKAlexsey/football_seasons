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

  get "/api/seasons/search" do
    {response_conn, status, body} = SearchSeasons.make_search_response(conn)
    send_resp(response_conn, status, body)
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
