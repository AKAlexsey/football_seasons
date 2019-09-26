defmodule FootballSeasons.Caching.CacheRecordServiceTest do
  use FootballSeasons.MnesiaCase
  use FootballSeasons.DataCase

  alias FootballSeasons.Caching.CacheRecordService

  describe "#cache_games" do
    test "Move data from database to mnesia" do
      team1 = insert(:team)
      team2 = insert(:team)
      %{id: game1_id} = insert(:game, %{home_team_id: team1.id, away_team_id: team2.id})

      team3 = insert(:team)
      team4 = insert(:team)
      %{id: game2_id} = insert(:game, %{home_team_id: team3.id, away_team_id: team4.id})

      assert {:ok, nil} == read_mnesia(:game, game1_id)
      assert {:ok, nil} == read_mnesia(:game, game2_id)

      CacheRecordService.cache_games()

      assert {:ok, %{id: ^game1_id}} = read_mnesia(:game, game1_id)

      assert {:ok, %{id: ^game2_id}} = read_mnesia(:game, game2_id)
    end
  end
end
