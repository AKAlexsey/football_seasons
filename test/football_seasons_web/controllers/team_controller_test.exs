defmodule FootballSeasonsWeb.TeamControllerTest do
  use FootballSeasonsWeb.ConnCase

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:team) do
    insert(:team, @create_attrs)
  end

  describe "index" do
    setup [:authorize_user]

    test "lists all teams", %{conn: conn} do
      conn = get(conn, team_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Teams"
    end
  end

  describe "new team" do
    setup [:authorize_user]

    test "renders form", %{conn: conn} do
      conn = get(conn, team_path(conn, :new))
      assert html_response(conn, 200) =~ "New Team"
    end
  end

  describe "create team" do
    setup [:create_team, :authorize_user]

    test "redirects to show when data is valid", %{conn: conn} do
      resp_conn = post(conn, team_path(conn, :create), team: @create_attrs)

      assert %{id: id} = redirected_params(resp_conn)
      assert redirected_to(resp_conn) == team_path(resp_conn, :show, id)

      resp_conn = get(conn, team_path(conn, :show, id))
      assert html_response(resp_conn, 200) =~ "Show Team"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, team_path(conn, :create), team: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Team"
    end
  end

  describe "edit team" do
    setup [:create_team, :authorize_user]

    test "renders form for editing chosen team", %{conn: conn, team: team} do
      conn = get(conn, team_path(conn, :edit, team))
      assert html_response(conn, 200) =~ "Edit Team"
    end
  end

  describe "update team" do
    setup [:create_team, :authorize_user]

    test "redirects when data is valid", %{conn: conn, team: team} do
      resp_conn = put(conn, team_path(conn, :update, team), team: @update_attrs)
      assert redirected_to(resp_conn) == team_path(resp_conn, :show, team)

      resp_conn = get(conn, team_path(conn, :show, team))
      assert html_response(resp_conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, team: team} do
      conn = put(conn, team_path(conn, :update, team), team: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Team"
    end
  end

  describe "delete team" do
    setup [:create_team, :authorize_user]

    test "deletes chosen team", %{conn: conn, team: team} do
      resp_conn = delete(conn, team_path(conn, :delete, team))
      assert redirected_to(resp_conn) == team_path(resp_conn, :index)

      assert_error_sent 404, fn ->
        get(conn, team_path(conn, :show, team))
      end
    end
  end

  defp create_team(_) do
    team = fixture(:team)
    {:ok, team: team}
  end
end
