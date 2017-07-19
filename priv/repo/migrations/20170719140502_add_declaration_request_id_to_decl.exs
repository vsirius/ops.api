defmodule OPS.Repo.Migrations.AddDeclarationRequestIdToDecl do
  use Ecto.Migration

  def change do
    alter table(:declarations) do
      add :declaration_request_id, :uuid, null: false
    end

    execute "create extension \"uuid-ossp\";"
    execute "update declarations set declaration_request_id = uuid_generate_v4() where declaration_request_id is null;"
  end
end
