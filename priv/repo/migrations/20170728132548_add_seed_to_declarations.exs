defmodule OPS.Repo.Migrations.AddSeedToDeclarations do
  use Ecto.Migration

  def change do
    alter table(:declarations) do
      add :seed, :string, null: false
    end
  end
end
