defmodule OPS.Declaration.ReportTest do
  use OPS.DataCase

  alias OPS.DeclarationAPI
  alias OPS.Declaration

  @create_attrs %{
    person_id: Ecto.UUID.generate(),
    start_date: "2016-10-10 23:50:07.000000",
    end_date: "2016-12-07 23:50:07.000000",
    status: "status",
    signed_at: "2016-10-09 23:50:07.000000",
    created_by: "some_author_identifier",
    updated_by: "some_editor_identifier",
    is_active: true,
    scope: "some_scope_string",
    employee_id: Ecto.UUID.generate(),
    division_id: Ecto.UUID.generate(),
    legal_entity_id: Ecto.UUID.generate(),
  }

  def fixture(:declaration, attrs \\ @create_attrs) do
    create_attrs =
      attrs
      |> Map.put_new(:employee_id, Ecto.UUID.generate())
      |> Map.put_new(:legal_entity_id, Ecto.UUID.generate())

    {:ok, declaration} = DeclarationAPI.create_declaration(create_attrs)
    declaration
  end

#  test "report" do
#    declaration = fixture(:declaration)
#    params = %{
#      "start_date" => "2016-12-09",
#      "end_date" => "2017-12-09",
#      "employee_id" => declaration.employee_id,
#      "legal_entity_id" => declaration.legal_entity_id
#    }
#    assert {:ok, list} = OPS.Declaration.Report.report(params)
#    assert is_list(list)
#  end
end
