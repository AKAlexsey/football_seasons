defmodule FootballSeasons.Caching.CacheRecordService do
  @moduledoc """
  Request 'games' with preloaded 'teams' and pass them to MnesiaRecordHandler
  """

  alias FootballSeasons.Caching.Game
  alias FootballSeasons.Caching.MnesiaRecordHandler
  alias FootballSeasons.Seasons

  def cache_games do
    [:home_team, :away_team]
    |> Seasons.list_games()
    |> Enum.map(fn game ->
      MnesiaRecordHandler.perform(:cache, game)
    end)
  end

  def reset_mnesia do
    File.rm_rf("#{File.cwd!()}/#{Application.get_env(:mnesia, :dir)}")
    :mnesia.stop()
    Memento.Schema.create([Node.self()])
    :mnesia.start()
    Memento.Table.create(Game)
  end
end
