defmodule CharacterSheet.Repo do
  use Ecto.Repo,
    otp_app: :character_sheet,
    adapter: Ecto.Adapters.Postgres
end
