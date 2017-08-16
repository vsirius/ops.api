defmodule OPS.Repo.Migrations.AddNewTables do
  use Ecto.Migration

  def change do
    create table(:signed_declarations, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :signed_data, :bytea, null: false
    end

    create table(:seeds, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :hash, :string, null: false
      add :inserted_at, :utc_datetime, null: false
    end

    execute "INSERT INTO seeds (id, hash, inserted_at)
                  VALUES (uuid_generate_v4(), 'Слава Україні!', now());"
  end
end
