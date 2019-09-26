defmodule FootballSeasons.Caching.GameTest do
  use FootballSeasons.MnesiaCase
  use FootballSeasons.DataCase

  alias FootballSeasons.Caching.Game

  describe "#make_division_and_season" do
    test "Return right result" do
      division = Faker.Lorem.word()
      season = Faker.Lorem.word()
      assert Game.make_division_and_season(division, season) == "#{division}_#{season}"
    end
  end
end
