defmodule OPS.AuditLogs do
  @defmodule false

  alias OPS.Repo
  import Ecto.{Query, Changeset}

  alias OPS.AuditLog

  def create_audit_log(attrs \\ %{}) do
    %AuditLog{}
    |> audit_log_changeset(attrs)
    |> Repo.insert
  end

  def audit_log_changeset(%AuditLog{} = audit_log, attrs) do
    fields = ~W(
      actor_id
      resource
      resource_id
      changeset
    )a

    audit_log
    |> cast(attrs, fields)
    |> validate_required(fields)
  end
end
