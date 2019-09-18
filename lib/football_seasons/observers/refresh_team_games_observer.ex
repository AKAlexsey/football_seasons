defmodule FootballSeasons.RefreshTeamGamesObserver do
  @moduledoc """
  Perform refreshing records in mnesia 'Game table' for 'games' connected to given 'team'
  """

  use Observable, :observer

  alias FootballSeasons.Caching.RefreshTeamGamesService

  def handle_notify(_action, {_repo, _old, record}) do
    Task.async(fn ->
      RefreshTeamGamesService.perform(record)
    end)

    :ok
  end
end
