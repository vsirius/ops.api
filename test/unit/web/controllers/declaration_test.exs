defmodule OPS.Web.DeclarationControllerTest do
  use OPS.Web.ConnCase

  alias OPS.DeclarationAPI
  alias OPS.Declaration

  @create_attrs %{
    employee_id: "employee_id",
    person_id: "person_id",
    start_date: "2016-10-10 00:00:00.000000",
    end_date: "2016-12-07 00:00:00.000000",
    status: "active",
    signed_at: "2016-10-09 23:50:07.000000",
    created_by: Ecto.UUID.generate(),
    updated_by: Ecto.UUID.generate(),
    is_active: true,
    scope: "family_doctor",
    division_id: Ecto.UUID.generate(),
    legal_entity_id: "legal_entity_id",
  }

  @update_attrs %{
    employee_id: "updated_employee_id",
    person_id: "updated_person_id",
    start_date: "2016-10-11 00:00:00.000000",
    end_date: "2016-12-08 00:00:00.000000",
    status: "closed",
    signed_at: "2016-10-10 23:50:07.000000",
    created_by: Ecto.UUID.generate(),
    updated_by: Ecto.UUID.generate(),
    is_active: false,
    scope: "family_doctor",
    division_id: Ecto.UUID.generate(),
    legal_entity_id: "updated_legal_entity_id",
  }

   @invalid_attrs %{
     division_id: "invalid"
   }

  def fixture(:declaration, attrs \\ @create_attrs) do
    create_attrs =
      attrs
      |> Map.put(:employee_id, Ecto.UUID.generate())
      |> Map.put(:legal_entity_id, Ecto.UUID.generate())

    {:ok, declaration} = DeclarationAPI.create_declaration(create_attrs)
    declaration
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, declaration_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "searches entries", %{conn: conn} do
    %{employee_id: doctor_id_1} = fixture(:declaration)
    %{employee_id: doctor_id_2} = fixture(:declaration)

    conn = get conn, declaration_path(conn, :index) <> "?employee_id=#{doctor_id_1}"

    assert [resp_declaration] = json_response(conn, 200)["data"]
    assert doctor_id_1 == resp_declaration["employee_id"]
    refute doctor_id_2 == resp_declaration["employee_id"]
  end

  test "returns errors when searching entries", %{conn: conn} do
    conn = get conn, declaration_path(conn, :index) <> "?created_by=nil"
    assert json_response(conn, 422)["error"]
  end

  test "creates declaration and renders declaration when data is valid", %{conn: conn} do
    conn = post conn, declaration_path(conn, :create), declaration: @create_attrs
    assert %{"id" => id, "inserted_at" => inserted_at, "updated_at" => updated_at} = json_response(conn, 201)["data"]

    conn = get conn, declaration_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "person_id" => "person_id",
      "employee_id" => "employee_id",
      "division_id" => @create_attrs.division_id,
      "legal_entity_id" => "legal_entity_id",
      "scope" => "family_doctor",
      "start_date" => "2016-10-10T00:00:00.000000Z",
      "end_date" => "2016-12-07T00:00:00.000000Z",
      "signed_at" => "2016-10-09T23:50:07.000000Z",
      "status" => "active",
      "inserted_at" => inserted_at,
      "created_by" => @create_attrs.created_by,
      "updated_at" => updated_at,
      "updated_by" => @create_attrs.updated_by,
      "type" => "declaration"
    }
  end

  @tag pending: true
  test "does not create declaration and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, declaration_path(conn, :create), declaration: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "creates declaration and terminates other person declarations when data is valid", %{conn: conn} do
    %{id: id1} = fixture(:declaration)
    %{id: id2} = fixture(:declaration, Map.put(@create_attrs, :person_id, "another_person_id"))
    conn = post conn, declaration_path(conn, :create_with_termination_logic), @create_attrs
    resp = json_response(conn, 200)
    assert Map.has_key?(resp, "data")
    assert Map.has_key?(resp["data"], "id")
    id = resp["data"]["id"]
    assert id

    %{id: ^id} = DeclarationAPI.get_declaration!(id)

    %{status: status} = DeclarationAPI.get_declaration!(id1)
    assert "terminated" == status

    %{status: status} = DeclarationAPI.get_declaration!(id2)
    assert "active" == status
  end

  test "doesn't terminate other declarations and renders errors when data is invalid", %{conn: conn} do
    %{id: id} = fixture(:declaration)
    invalid_attrs = Map.put(@invalid_attrs, :person_id, "person_id")
    conn = post conn, declaration_path(conn, :create_with_termination_logic), invalid_attrs
    resp = json_response(conn, 422)
    assert Map.has_key?(resp, "error")

    %{status: status} = DeclarationAPI.get_declaration!(id)
    assert "active" == status
  end

  test "updates chosen declaration and renders declaration when data is valid", %{conn: conn} do
    %Declaration{id: id} = declaration = fixture(:declaration)
    conn = put conn, declaration_path(conn, :update, declaration), declaration: @update_attrs
    assert %{"id" => ^id, "inserted_at" => inserted_at, "updated_at" => updated_at} = json_response(conn, 200)["data"]

    conn = get conn, declaration_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "person_id" => "updated_person_id",
      "employee_id" => "updated_employee_id",
      "division_id" => @update_attrs.division_id,
      "legal_entity_id" => "updated_legal_entity_id",
      "scope" => "family_doctor",
      "start_date" => "2016-10-11T00:00:00.000000Z",
      "end_date" => "2016-12-08T00:00:00.000000Z",
      "signed_at" => "2016-10-10T23:50:07.000000Z",
      "status" => "closed",
      "inserted_at" => inserted_at,
      "created_by" => @update_attrs.created_by,
      "updated_at" => updated_at,
      "updated_by" => @update_attrs.updated_by,
      "type" => "declaration"
    }
  end

  @tag pending: true
  test "does not update chosen declaration and renders errors when data is invalid", %{conn: conn} do
    declaration = fixture(:declaration)
    conn = put conn, declaration_path(conn, :update, declaration), declaration: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen declaration", %{conn: conn} do
    declaration = fixture(:declaration)
    conn = delete conn, declaration_path(conn, :delete, declaration)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, declaration_path(conn, :show, declaration)
    end
  end
end
