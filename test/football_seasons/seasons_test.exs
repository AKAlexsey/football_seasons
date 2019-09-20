defmodule FootballSeasons.SeasonsTest do
  use FootballSeasons.DataCase

  alias FootballSeasons.Seasons

  describe "teams" do
    alias FootballSeasons.Seasons.Team

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    test "list_teams/0 returns all teams" do
      team = insert(:team, @valid_attrs)
      assert Seasons.list_teams() == [team]
    end

    test "get_team!/1 returns the team with given id" do
      team = insert(:team, @valid_attrs)
      assert Seasons.get_team!(team.id) == team
    end

    test "create_team/1 with valid data creates a team" do
      assert %Team{} = team = insert(:team, @valid_attrs)
      assert team.name == "some name"
    end

    test "create_team/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Seasons.create_team(@invalid_attrs)
    end

    test "update_team/2 with valid data updates the team" do
      team = insert(:team, @valid_attrs)
      assert {:ok, %Team{} = team} = Seasons.update_team(team, @update_attrs)
      assert team.name == "some updated name"
    end

    test "update_team/2 with invalid data returns error changeset" do
      team = insert(:team, @valid_attrs)
      assert {:error, %Ecto.Changeset{}} = Seasons.update_team(team, @invalid_attrs)
      assert team == Seasons.get_team!(team.id)
    end

    test "delete_team/1 deletes the team" do
      team = insert(:team, @valid_attrs)
      assert {:ok, %Team{}} = Seasons.delete_team(team)
      assert_raise Ecto.NoResultsError, fn -> Seasons.get_team!(team.id) end
    end

    test "change_team/1 returns a team changeset" do
      team = insert(:team, @valid_attrs)
      assert %Ecto.Changeset{} = Seasons.change_team(team)
    end
  end

  describe "games" do
    alias FootballSeasons.Seasons.Game

    @valid_attrs %{
      date: ~D[2010-04-17],
      division: "some division",
      ftag: 42,
      fthg: 42,
      htag: 42,
      hthg: 42,
      season: "some season"
    }
    @update_attrs %{
      date: ~D[2011-05-18],
      division: "some updated division",
      ftag: 43,
      fthg: 43,
      htag: 43,
      hthg: 43,
      season: "some updated season"
    }
    @invalid_attrs %{
      away_team_id: nil,
      date: nil,
      division: nil,
      ftag: nil,
      fthg: nil,
      home_team_id: nil,
      htag: nil,
      hthg: nil,
      season: nil
    }

    test "list_games/0 returns all games" do
      game = insert(:game, @valid_attrs)
      assert Seasons.list_games() == [game]
    end

    test "get_game!/1 returns the game with given id" do
      game = insert(:game, @valid_attrs)
      assert Seasons.get_game!(game.id) == game
    end

    test "create_game/1 with valid data creates a game" do
      assert %Game{} = game = insert(:game, @valid_attrs)
      assert game.date == ~D[2010-04-17]
      assert game.division == "some division"
      assert game.ftag == 42
      assert game.fthg == 42
      assert game.htag == 42
      assert game.hthg == 42
      assert game.season == "some season"
    end

    test "create_game/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Seasons.create_game(@invalid_attrs)
    end

    test "update_game/2 with valid data updates the game" do
      game = insert(:game, @valid_attrs)
      assert {:ok, %Game{} = game} = Seasons.update_game(game, @update_attrs)
      assert game.date == ~D[2011-05-18]
      assert game.division == "some updated division"
      assert game.ftag == 43
      assert game.fthg == 43
      assert game.htag == 43
      assert game.hthg == 43
      assert game.season == "some updated season"
    end

    test "update_game/2 with invalid data returns error changeset" do
      game = insert(:game, @valid_attrs)
      assert {:error, %Ecto.Changeset{}} = Seasons.update_game(game, @invalid_attrs)
      assert game == Seasons.get_game!(game.id)
    end

    test "delete_game/1 deletes the game" do
      game = insert(:game, @valid_attrs)
      assert {:ok, %Game{}} = Seasons.delete_game(game)
      assert_raise Ecto.NoResultsError, fn -> Seasons.get_game!(game.id) end
    end

    test "change_game/1 returns a game changeset" do
      game = insert(:game, @valid_attrs)
      assert %Ecto.Changeset{} = Seasons.change_game(game)
    end
  end
end
