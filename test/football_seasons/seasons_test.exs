defmodule FootballSeasons.SeasonsTest do
  use FootballSeasons.DataCase

  alias FootballSeasons.Seasons

  describe "teams" do
    alias FootballSeasons.Seasons.Team

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def team_fixture(attrs \\ %{}) do
      {:ok, team} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Seasons.create_team()

      team
    end

    test "list_teams/0 returns all teams" do
      team = team_fixture()
      assert Seasons.list_teams() == [team]
    end

    test "get_team!/1 returns the team with given id" do
      team = team_fixture()
      assert Seasons.get_team!(team.id) == team
    end

    test "create_team/1 with valid data creates a team" do
      assert {:ok, %Team{} = team} = Seasons.create_team(@valid_attrs)
      assert team.name == "some name"
    end

    test "create_team/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Seasons.create_team(@invalid_attrs)
    end

    test "update_team/2 with valid data updates the team" do
      team = team_fixture()
      assert {:ok, %Team{} = team} = Seasons.update_team(team, @update_attrs)
      assert team.name == "some updated name"
    end

    test "update_team/2 with invalid data returns error changeset" do
      team = team_fixture()
      assert {:error, %Ecto.Changeset{}} = Seasons.update_team(team, @invalid_attrs)
      assert team == Seasons.get_team!(team.id)
    end

    test "delete_team/1 deletes the team" do
      team = team_fixture()
      assert {:ok, %Team{}} = Seasons.delete_team(team)
      assert_raise Ecto.NoResultsError, fn -> Seasons.get_team!(team.id) end
    end

    test "change_team/1 returns a team changeset" do
      team = team_fixture()
      assert %Ecto.Changeset{} = Seasons.change_team(team)
    end
  end

  describe "games" do
    alias FootballSeasons.Seasons.Game

    @valid_attrs %{
      away_team_id: 42,
      date: ~D[2010-04-17],
      division: "some division",
      ftag: 42,
      fthg: 42,
      home_team_id: 42,
      htag: 42,
      hthg: 42,
      season: "some season"
    }
    @update_attrs %{
      away_team_id: 43,
      date: ~D[2011-05-18],
      division: "some updated division",
      ftag: 43,
      fthg: 43,
      home_team_id: 43,
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

    def game_fixture(attrs \\ %{}) do
      {:ok, game} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Seasons.create_game()

      game
    end

    test "list_games/0 returns all games" do
      game = game_fixture()
      assert Seasons.list_games() == [game]
    end

    test "get_game!/1 returns the game with given id" do
      game = game_fixture()
      assert Seasons.get_game!(game.id) == game
    end

    test "create_game/1 with valid data creates a game" do
      assert {:ok, %Game{} = game} = Seasons.create_game(@valid_attrs)
      assert game.away_team_id == 42
      assert game.date == ~D[2010-04-17]
      assert game.division == "some division"
      assert game.ftag == 42
      assert game.fthg == 42
      assert game.home_team_id == 42
      assert game.htag == 42
      assert game.hthg == 42
      assert game.season == "some season"
    end

    test "create_game/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Seasons.create_game(@invalid_attrs)
    end

    test "update_game/2 with valid data updates the game" do
      game = game_fixture()
      assert {:ok, %Game{} = game} = Seasons.update_game(game, @update_attrs)
      assert game.away_team_id == 43
      assert game.date == ~D[2011-05-18]
      assert game.division == "some updated division"
      assert game.ftag == 43
      assert game.fthg == 43
      assert game.home_team_id == 43
      assert game.htag == 43
      assert game.hthg == 43
      assert game.season == "some updated season"
    end

    test "update_game/2 with invalid data returns error changeset" do
      game = game_fixture()
      assert {:error, %Ecto.Changeset{}} = Seasons.update_game(game, @invalid_attrs)
      assert game == Seasons.get_game!(game.id)
    end

    test "delete_game/1 deletes the game" do
      game = game_fixture()
      assert {:ok, %Game{}} = Seasons.delete_game(game)
      assert_raise Ecto.NoResultsError, fn -> Seasons.get_game!(game.id) end
    end

    test "change_game/1 returns a game changeset" do
      game = game_fixture()
      assert %Ecto.Changeset{} = Seasons.change_game(game)
    end
  end
end
