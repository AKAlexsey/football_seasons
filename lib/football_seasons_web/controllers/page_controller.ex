defmodule FootballSeasonsWeb.PageController do
  use FootballSeasonsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
