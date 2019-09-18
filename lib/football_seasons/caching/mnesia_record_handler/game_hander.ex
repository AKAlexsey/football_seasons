defmodule FootballSeasons.Caching.MnesiaRecordHandler.GameHandler do
  @moduledoc """
  Handle writing record to Mnesia database.
  Add field :division_and_season for searching by both fields with index.
  """

  alias FootballSeasons.Caching.Game

  def handle(:delete, %{id: id} = attrs) do
    Memento.transaction(fn -> Memento.Query.delete(Game, id) end)
  end

  def handle(_action, %{division: division, season: season} = attrs) do
    Memento.transaction(fn ->
      %Game{}
      |> Map.merge(attrs)
      |> Map.put(:division_and_season, Game.make_division_and_season(division, season))
      |> Memento.Query.write()
    end)
  end
end
