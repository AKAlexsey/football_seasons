defmodule FootballSeasons.Caching.SearchSeasons do
  @moduledoc """
  Process plug request.
  Return response parameters, status, response data
  """

  alias FootballSeasons.Caching.SearchGameService

  @spec make_index_response(Plug.Conn.t()) :: {Plug.Conn.t(), integer, binary}
  def make_index_response(%Plug.Conn{} = conn) do
    json_response = SearchGameService.all_games()

    {conn, 200, json_response}
  end

  @spec make_search_response(Plug.Conn.t()) :: {Plug.Conn.t(), integer, binary}
  def make_search_response(%Plug.Conn{query_params: query_params} = conn) do
    json_response =
      query_params
      |> fetch_params()
      |> SearchGameService.search_games()

    {conn, 200, json_response}
  end

  @spec fetch_params(map) :: {binary | nil, binary | nil}
  defp fetch_params(query_params) do
    {
      Map.get(query_params, "division", nil),
      Map.get(query_params, "season", nil)
    }
  end
end
