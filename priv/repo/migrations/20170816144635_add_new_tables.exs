defmodule OPS.Repo.Migrations.AddNewTables do
  use Ecto.Migration

  def change do
    alter table(:declarations, primary_key: false) do
      add :signed_data, :bytea
    end

    create table(:seeds, primary_key: false) do
      add :hash, :string, null: false
      add :inserted_at, :utc_datetime, null: false
    end

    execute("INSERT INTO seeds (hash, inserted_at) VALUES (digest('Слава Україні!', 'sha512'), now());")
  end
end
