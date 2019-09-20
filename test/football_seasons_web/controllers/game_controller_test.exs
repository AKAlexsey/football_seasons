defmodule FootballSeasonsWeb.GameControllerTest do
  use FootballSeasonsWeb.ConnCase

  @create_attrs %{
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

  describe "index" do
    setup [:authorize_user]

    test "lists all games", %{conn: conn} do
      conn = get(conn, game_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Games"
    end
  end

  describe "new game" do
    setup [:authorize_user]

    test "renders form", %{conn: conn} do
      conn = get(conn, game_path(conn, :new))
      assert html_response(conn, 200) =~ "New Game"
    end
  end

  describe "create game" do
    setup [:authorize_user]

    test "redirects to show when data is valid", %{conn: conn} do
      %{id: home_team_id} = insert(:team)
      %{id: away_team_id} = insert(:team)

      attrs = Map.merge(@create_attrs, %{home_team_id: home_team_id, away_team_id: away_team_id})

      resp_conn = post(conn, game_path(conn, :create), game: attrs)

      assert %{id: id} = redirected_params(resp_conn)
      assert redirected_to(resp_conn) == game_path(resp_conn, :show, id)

      resp_conn = get(conn, game_path(conn, :show, id))
      assert html_response(resp_conn, 200) =~ "Show Game"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, game_path(conn, :create), game: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Game"
    end
  end

  describe "edit game" do
    setup [:create_game, :authorize_user]

    test "renders form for editing chosen game", %{conn: conn, game: game} do
      conn = get(conn, game_path(conn, :edit, game))
      assert html_response(conn, 200) =~ "Edit Game"
    end
  end

  describe "update game" do
    setup [:create_game, :authorize_user]

    test "redirects when data is valid", %{conn: conn, game: game} do
      resp_conn = put(conn, game_path(conn, :update, game), game: @update_attrs)
      assert redirected_to(resp_conn) == game_path(resp_conn, :show, game)

      resp_conn = get(conn, game_path(conn, :show, game))
      assert html_response(resp_conn, 200) =~ "some updated division"
    end

    test "renders errors when data is invalid", %{conn: conn, game: game} do
      conn = put(conn, game_path(conn, :update, game), game: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Game"
    end
  end

  describe "delete game" do
    setup [:create_game, :authorize_user]

    test "deletes chosen game", %{conn: conn, game: game} do
      resp_conn = delete(conn, game_path(conn, :delete, game))
      assert redirected_to(resp_conn) == game_path(resp_conn, :index)

      assert_error_sent 404, fn ->
        get(conn, game_path(conn, :show, game))
      end
    end
  end

  defp create_game(_) do
    game = insert(:game)
    {:ok, game: game}
  end
end
