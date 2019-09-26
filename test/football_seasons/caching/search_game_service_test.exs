defmodule FootballSeasons.Caching.SearchGameServiceTest do
  use FootballSeasons.MnesiaCase
  use FootballSeasons.DataCase

  alias FootballSeasons.Caching.{CacheRecordService, SearchGameService}

  describe "#all_games" do
    test "Return empty list if no games" do
      CacheRecordService.cache_games()

      result = all_games_result("json")
      assert [] == result
    end

    test "Return empty charlist list if no games" do
      CacheRecordService.cache_games()

      result = all_games_result("protobuf")
      assert <<>> == result
    end

    test "Return all games from database" do
      game1 = insert(:game)
      game2 = insert(:game)
      game3 = insert(:game)

      CacheRecordService.cache_games()

      result = all_games_result("json")

      assert element_present_in_collection(result, game1)
      assert element_present_in_collection(result, game2)
      assert element_present_in_collection(result, game3)
      assert length(result) == 3
    end

    test "Return all games from database in charlist format" do
      insert(:game)
      insert(:game)
      insert(:game)

      CacheRecordService.cache_games()

      result = all_games_result("protobuf")
      assert result != <<>>
      assert is_bitstring(result)
    end
  end

  describe "#search_games" do
    test "Return filtered games" do
      division1 = "D1"
      division2 = "D2"
      division3 = "D3"
      season1 = "201718"
      season2 = "201819"

      game1 = insert(:game, %{division: division1, season: season1})
      game2 = insert(:game, %{division: division2, season: season1})
      game3 = insert(:game, %{division: division3, season: season2})

      CacheRecordService.cache_games()

      result = search_games_result({division1, nil}, "json")
      assert length(result) == 1
      assert element_present_in_collection(result, game1)

      result = search_games_result({nil, season1}, "json")
      assert length(result) == 2
      assert element_present_in_collection(result, game1)
      assert element_present_in_collection(result, game2)

      result = search_games_result({division3, season2}, "json")
      assert length(result) == 1
      assert element_present_in_collection(result, game3)

      assert <<>> == search_games_result({nil, nil}, "protobuf")
    end
  end

  def all_games_result("json") do
    "json"
    |> SearchGameService.all_games()
    |> Jason.decode!()
  end

  def all_games_result(encoding) do
    encoding
    |> SearchGameService.all_games()
  end

  def search_games_result({division, season}, "json") do
    {division, season, "json"}
    |> SearchGameService.search_games()
    |> Jason.decode!()
  end

  def search_games_result({division, season}, _protobuf_probably) do
    {division, season, "protobuf"}
    |> SearchGameService.search_games()
  end

  def get_valuable_params(params) do
    params
    |> Map.take(~w(date division season))
    |> Map.take([:date, :division, :season])
  end

  def element_present_in_collection(collection, element) do
    assert Enum.any?(collection, fn el ->
             get_valuable_params(el) == get_valuable_params(element)
           end)
  end
end
