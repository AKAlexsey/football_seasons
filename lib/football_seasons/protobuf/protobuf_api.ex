defmodule FootballSeasons.ProtobufApi do
  use Protobuf, from: Path.expand(Application.get_env(:football_seasons, :plug_configuration)[:proto_path], File.cwd!())
end
