defmodule FootballSeasons.Caching.RefreshTeamGamesService do
  @moduledoc """
  Request 'games' with preloaded 'teams' and pass them to MnesiaRecordHandler
  """

  alias FootballSeasons.Caching.MnesiaRecordHandler
  alias FootballSeasons.Seasons

  def perform(record) do
    record
    |> Seasons.get_team_games()
    |> Enum.each(fn game ->
      MnesiaRecordHandler.perform(:cache, game)
    end)
  end
end
