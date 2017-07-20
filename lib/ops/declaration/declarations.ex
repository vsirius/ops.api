defmodule OPS.Declarations do
  @moduledoc """
  The boundary for the Declarations system
  """

  use OPS.Search
  import Ecto.{Query, Changeset}, warn: false
  alias Ecto.Multi
  alias OPS.Repo

  alias OPS.AuditLogs
  alias OPS.Declarations.Declaration
  alias OPS.Declarations.DeclarationSearch

  def list_declarations(params) do
    %DeclarationSearch{}
    |> declaration_changeset(params)
    |> search(params, Declaration, 50)
  end

  def get_declaration!(id), do: Repo.get!(Declaration, id)

  # TODO: Make more clearly getting created_by and updated_by parameters
  def create_declaration(attrs \\ %{}) do
    %Declaration{}
    |> declaration_changeset(attrs)
    |> Repo.insert_and_log(Map.get(attrs, "created_by", Map.get(attrs, :created_by)))
  end

  def update_declaration(%Declaration{} = declaration, attrs) do
    declaration
    |> declaration_changeset(attrs)
    |> Repo.update_and_log(Map.get(attrs, "updated_by", Map.get(attrs, :updated_by)))
  end

  def delete_declaration(%Declaration{} = declaration) do
    Repo.delete(declaration)
  end

  def change_declaration(%Declaration{} = declaration) do
    declaration_changeset(declaration, %{})
  end

  defp declaration_changeset(%Declaration{} = declaration, attrs) do
    fields = ~W(
      employee_id
      person_id
      start_date
      end_date
      status
      signed_at
      created_by
      updated_by
      is_active
      scope
      division_id
      legal_entity_id
      declaration_request_id
    )a

    declaration
    |> cast(attrs, fields)
    |> validate_required(fields)
    |> validate_state_transition()
    |> validate_inclusion(:scope, ["family_doctor"])
    |> validate_inclusion(:status, ["active", "closed", "terminated", "pending_verification"])
  end

  defp declaration_changeset(%DeclarationSearch{} = declaration, attrs) do
    fields = ~W(
      person_id
      is_active
      employee_id
      legal_entity_id
    )

    cast(declaration, attrs, fields)
  end

  def create_declaration_with_termination_logic(%{"person_id" => person_id} = declaration_params) do
    # TODO: Red Lists
    changeset = declaration_changeset(%DeclarationSearch{}, %{"person_id" => person_id, "status" => "active"})

    query = from d in Declaration,
      where: ^Map.to_list(changeset.changes)

    Multi.new()
    |> Multi.update_all(:previous_declarations, query, set: [status: "terminated"])
    |> Multi.insert(:new_declaration, declaration_changeset(%Declaration{}, declaration_params))
    |> Repo.transaction()
  end

  def terminate_declarations(user_id, employee_id) do
    query = from d in Declaration,
      where: [status: "active", employee_id: ^employee_id]

    updates = [status: "terminated", updated_by: user_id]

    Multi.new
    |> Multi.update_all(:terminated_declarations, query, [set: updates], returning: [:id])
    |> Multi.run(:logged_terminations, fn multi -> log_updates(user_id, multi.terminated_declarations, updates) end)
    |> Repo.transaction()
  end

  def log_updates(user_id, {_, terminated_declarations}, updates) do
    changeset = Enum.into(updates, %{updated_by: user_id})

    updates =
      Enum.reduce terminated_declarations, [], fn declaration, acc ->
        AuditLogs.create_audit_log(%{
          actor_id: user_id,
          resource: "declaration",
          resource_id: declaration.id,
          changeset: changeset
        })

        [declaration.id|acc]
      end

    {:ok, updates}
  end

  def reject_declaration(declaration) do
    declaration
    |> change
    |> validate_acceptance(:is_active)
    |> validate_inclusion(:status, ["pending_verification"])
    |> Repo.update
  end
end
