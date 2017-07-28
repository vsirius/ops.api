defmodule OPS.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: OPS.Repo

  alias OPS.Declarations.Declaration

  def declaration_factory do
    day = 60 * 60 * 24
    start_date = NaiveDateTime.utc_now() |> NaiveDateTime.add(-10 * day, :seconds)
    end_date = NaiveDateTime.add(start_date, day, :seconds)
    %Declaration{
      declaration_request_id: Ecto.UUID.generate,
      start_date: start_date,
      end_date: end_date,
      status: Declaration.status(:active),
      signed_at: start_date,
      created_by: Ecto.UUID.generate,
      updated_by: Ecto.UUID.generate,
      employee_id: Ecto.UUID.generate,
      person_id: Ecto.UUID.generate,
      division_id: Ecto.UUID.generate,
      legal_entity_id: Ecto.UUID.generate,
      is_active: true,
      scope: "",
      seed: "some seed"
    }
  end
end
