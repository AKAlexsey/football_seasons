defmodule FootballSeasons.Caching.Game do
  @moduledoc """
  Define mnesia table those cache for 'games' DB table
  """

  use Memento.Table,
    attributes: [
      :id,
      :division,
      :season,
      :division_and_season,
      :date,
      :home_team_name,
      :away_team_name,
      :hthg,
      :htag,
      :htr,
      :fthg,
      :ftag,
      :ftr,
      :jason_cache
    ],
    index: [:division, :season, :division_and_season, :date, :home_team_name, :away_team_name],
    type: :ordered_set

  def make_division_and_season(division, season) do
    "#{division}_#{season}"
  end
end
