defmodule FootballSeasons.Caching.SearchSeasons do
  @moduledoc """
  Process plug request.
  Return response parameters, status, response data
  """

  @division_param_name "division"
  @season_param_name "season"
  @serialization_param_name "protocol"
  @default_serialization "json"

  alias FootballSeasons.Caching.SearchGameService

  @spec make_index_response(Plug.Conn.t()) :: {Plug.Conn.t(), integer, binary}
  def make_index_response(%Plug.Conn{query_params: query_params} = conn) do
    json_response =
      query_params
      |> fetch_encoding()
      |> SearchGameService.all_games()

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
      Map.get(query_params, @division_param_name, nil),
      Map.get(query_params, @season_param_name, nil),
      fetch_encoding(query_params)
    }
  end

  defp fetch_encoding(query_params),
    do: Map.get(query_params, @serialization_param_name, @default_serialization)
end
