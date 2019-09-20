defprotocol MnesiaCacheable do
  @moduledoc """
  Protocol for sending data to mnesia handlers.
  """

  @doc """
  Perform preparation data before sending eg sanitizing attributes with white list.
  """
  @spec serialize(map) :: map
  def serialize(record)
end
