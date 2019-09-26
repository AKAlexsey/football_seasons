defmodule FootballSeasons.Caching.MnesiaRecordHandlerTest do
  use FootballSeasons.MnesiaCase
  use FootballSeasons.DataCase

  alias FootballSeasons.Caching.MnesiaRecordHandler

  describe "#perform" do
    test "Insert record in mnesia if action is :insert. Delete in case of :delete" do
      %{id: team1_id, name: team1_name} = insert(:team)
      %{id: team2_id, name: team2_name} = insert(:team)
      %{id: game1_id} = game = insert(:game, %{home_team_id: team1_id, away_team_id: team2_id})

      assert {:ok, nil} == read_mnesia(:game, game1_id)

      assert {:ok, %{}} = MnesiaRecordHandler.perform(:insert, game)

      assert {:ok, %{id: ^game1_id, home_team_name: ^team1_name, away_team_name: ^team2_name}} =
               read_mnesia(:game, game1_id)

      assert :ok = MnesiaRecordHandler.perform(:delete, game)

      assert {:ok, nil} == read_mnesia(:game, game1_id)
    end
  end
end
