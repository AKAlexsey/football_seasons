defmodule FootballSeasonsWeb.UserControllerTest do
  use FootballSeasonsWeb.ConnCase

  @create_attrs %{
    email: "some email",
    is_admin: true,
    name: "some name",
    password_hash: "some password_hash"
  }
  @update_attrs %{
    email: "some updated email",
    is_admin: false,
    name: "some updated name",
    password_hash: "some updated password_hash"
  }
  @invalid_attrs %{email: nil, is_admin: nil, name: nil, password_hash: nil}

  describe "index" do
    setup [:authorize_user]

    test "lists all users", %{conn: conn} do
      conn = get(conn, user_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Users"
    end
  end

  describe "new user for authorized user" do
    setup [:authorize_user]

    test "renders new user form", %{conn: conn} do
      conn = get(conn, user_path(conn, :new))
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "new user for not authorized user" do
    test "renders registration form", %{conn: conn} do
      conn = get(conn, user_path(conn, :new))
      assert html_response(conn, 200) =~ "Registration"
    end
  end

  describe "create user" do
    setup [:authorize_user]

    test "redirects to show when data is valid", %{conn: conn} do
      resp_conn = post(conn, user_path(conn, :create), user: @create_attrs)

      assert %{id: id} = redirected_params(resp_conn)
      assert redirected_to(resp_conn) == user_path(resp_conn, :show, id)

      resp_conn = get(conn, user_path(conn, :show, id))
      assert html_response(resp_conn, 200) =~ "Show User"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      resp_conn = post(conn, user_path(conn, :create), user: @invalid_attrs)
      assert html_response(resp_conn, 200) =~ "New User"
    end
  end

  describe "edit user" do
    setup [:create_user, :authorize_user]

    test "renders form for editing chosen user", %{conn: conn, user: user} do
      conn = get(conn, user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "update user" do
    setup [:create_user, :authorize_user]

    test "redirects when data is valid", %{conn: conn, user: user} do
      resp_conn = put(conn, user_path(conn, :update, user), user: @update_attrs)
      assert redirected_to(resp_conn) == user_path(resp_conn, :show, user)

      resp_conn = get(conn, user_path(conn, :show, user))
      assert html_response(resp_conn, 200) =~ "some updated email"
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, user_path(conn, :update, user), user: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "delete user" do
    setup [:authorize_user]

    test "deletes chosen user", %{conn: conn} do
      user = insert(:user)

      resp_conn = delete(conn, user_path(conn, :delete, user))
      assert redirected_to(resp_conn) == user_path(resp_conn, :index)

      assert_error_sent 404, fn ->
        get(conn, user_path(conn, :show, user))
      end
    end
  end

  defp create_user(_) do
    user = insert(:user)
    {:ok, user: user}
  end
end
