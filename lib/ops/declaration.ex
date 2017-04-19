defmodule OPS.Declaration do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias OPS.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "declarations" do
    field :declaration_signed_id, Ecto.UUID
    field :employee_id, :string
    field :person_id, :string
    field :start_date, :date
    field :end_date, :date
    field :status, :string
    field :signed_at, :utc_datetime
    field :created_by, Ecto.UUID
    field :updated_by, Ecto.UUID
    field :is_active, :boolean, default: false
    field :scope, :string
    field :division_id, Ecto.UUID
    field :legal_entity_id, :string

    timestamps(type: :utc_datetime)
  end
end
