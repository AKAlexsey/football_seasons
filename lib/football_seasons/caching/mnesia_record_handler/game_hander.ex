defmodule FootballSeasons.Caching.MnesiaRecordHandler.GameHandler do
  @moduledoc """
  Handle writing record to Mnesia database.
  Add field :division_and_season for searching by both fields with index.
  """

  alias FootballSeasons.Caching.Game
  alias FootballSeasons.ProtobufApi.Game, as: ProtobufGame

  def handle(:delete, %{id: id}) do
    Memento.transaction(fn -> Memento.Query.delete(Game, id) end)
  end

  def handle(_action, %{division: division, season: season} = attrs) do
    Memento.transaction(fn ->
      %Game{}
      |> Map.merge(attrs)
      |> Map.put(:division_and_season, Game.make_division_and_season(division, season))
      |> Map.put(:jason_cache, encode_params_for_caching(attrs))
      |> Map.put(:protobuf_cache, encode_protobuf_for_caching(attrs))
      |> Memento.Query.write()
    end)
  end

  defp encode_params_for_caching(attrs) do
    attrs
    |> Map.delete(:id)
    |> Jason.encode!()
  end

  defp encode_protobuf_for_caching(attrs) do
    attrs
    |> Map.delete(:id)
    |> Enum.map(fn
      {key, value} when is_binary(value) ->
        {key, String.to_charlist(value)}

      {key, value = %Date{}} ->
        {key, Date.to_string(value)}

      {key, value} ->
        {key, value}
    end)
    |> Enum.into(%{})
    |> ProtobufGame.new()
    |> ProtobufGame.encode()
  end
end
