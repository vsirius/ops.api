defmodule OPS.Repo.Migrations.ChangeDeclarations do
  use Ecto.Migration

  def change do
    alter table(:declarations) do
      remove :declaration_signed_id
      modify :start_date, :utc_datetime, null: false
      modify :end_date, :utc_datetime, null: false
    end
  end
end
