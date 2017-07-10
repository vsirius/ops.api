defmodule OPS.DeclarationTest do
  use OPS.DataCase

  alias OPS.Declarations
  alias OPS.Declarations.Declaration

  @create_attrs %{
    "employee_id" => Ecto.UUID.generate(),
    "person_id" => Ecto.UUID.generate(),
    "start_date" => "2016-10-10",
    "end_date" => "2016-12-07",
    "status" => "active",
    "signed_at" => "2016-10-09T23:50:07.000000Z",
    "created_by" => Ecto.UUID.generate(),
    "updated_by" => Ecto.UUID.generate(),
    "is_active" => true,
    "scope" => "family_doctor",
    "division_id" => Ecto.UUID.generate(),
    "legal_entity_id" => Ecto.UUID.generate(),
  }

  @update_attrs %{
    "employee_id" => Ecto.UUID.generate(),
    "person_id" => Ecto.UUID.generate(),
    "start_date" => "2016-10-11",
    "end_date" => "2016-12-08",
    "status" => "closed",
    "signed_at" => "2016-10-10T23:50:07.000000Z",
    "created_by" => Ecto.UUID.generate(),
    "updated_by" => Ecto.UUID.generate(),
    "is_active" => false,
    "scope" => "family_doctor",
    "division_id" => Ecto.UUID.generate(),
    "legal_entity_id" => Ecto.UUID.generate(),
  }

   @invalid_attrs %{
     "division_id" => "invalid"
   }

  def fixture(:declaration, attrs \\ @create_attrs) do
    create_attrs =
      attrs
      |> Map.put("employee_id", Ecto.UUID.generate())
      |> Map.put("legal_entity_id", Ecto.UUID.generate())


    {:ok, declaration} = Declarations.create_declaration(create_attrs)
    declaration
  end

  test "list_declarations/1 returns all declarations" do
    declaration = fixture(:declaration)
    assert Declarations.list_declarations(%{}) == {:ok, [declaration]}
  end

  test "get_declaration! returns the declaration with given id" do
    declaration = fixture(:declaration)
    assert Declarations.get_declaration!(declaration.id) == declaration
  end

  test "create_declaration/1 with valid data creates a declaration" do
    create_attrs =
      @create_attrs
      |> Map.put("employee_id", Ecto.UUID.generate())
      |> Map.put("legal_entity_id", Ecto.UUID.generate())

    assert {:ok, %Declaration{} = declaration} = Declarations.create_declaration(create_attrs)

    assert declaration.person_id == create_attrs["person_id"]
    assert declaration.start_date
    assert declaration.end_date
    assert declaration.status == "active"
    assert declaration.scope == "family_doctor"
    assert declaration.signed_at
    assert declaration.created_by == create_attrs["created_by"]
    assert declaration.updated_by == create_attrs["updated_by"]
    assert declaration.is_active
    assert declaration.employee_id == create_attrs["employee_id"]
    assert declaration.legal_entity_id == create_attrs["legal_entity_id"]
  end

  @tag pending: true
  test "create_declaration/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Declarations.create_declaration(@invalid_attrs)
  end

  describe "create_declaration_with_termination_logic/1" do
    test "with valid data creates declaration and terminates other person declarations" do
      %{id: id1} = fixture(:declaration)
      %{id: id2} = fixture(:declaration, Map.put(@create_attrs, "person_id", Ecto.UUID.generate()))
      {:ok, %{new_declaration: %{id: id}}} = Declarations.create_declaration_with_termination_logic(@create_attrs)

      %{id: ^id} = Declarations.get_declaration!(id)

      %{status: status} = Declarations.get_declaration!(id1)
      assert "terminated" == status

      %{status: status} = Declarations.get_declaration!(id2)
      assert "active" == status
    end

    test "with invalid data doesn't terminate other declarations and returns error changeset" do
      %{id: id} = fixture(:declaration)
      invalid_attrs = Map.put(@invalid_attrs, "person_id", "person_id")
      assert {:error, _transaction_step, %Ecto.Changeset{}, _}
        = Declarations.create_declaration_with_termination_logic(invalid_attrs)

      %{status: status} = Declarations.get_declaration!(id)
      assert "active" == status
    end
  end

  test "update_declaration/2 with valid data updates the declaration" do
    declaration = fixture(:declaration)
    assert {:ok, declaration} = Declarations.update_declaration(declaration, @update_attrs)
    assert %Declaration{} = declaration

    assert declaration.person_id == @update_attrs["person_id"]
    assert declaration.start_date
    assert declaration.end_date
    assert declaration.status == "closed"
    assert declaration.scope == "family_doctor"
    assert declaration.signed_at
    assert declaration.created_by == @update_attrs["created_by"]
    assert declaration.updated_by == @update_attrs["updated_by"]
    refute declaration.is_active
    assert declaration.employee_id == @update_attrs["employee_id"]
    assert declaration.legal_entity_id == @update_attrs["legal_entity_id"]
  end

  test "update_declaration/2 with invalid data returns error changeset" do
    declaration = fixture(:declaration)
    assert {:error, %Ecto.Changeset{}} = Declarations.update_declaration(declaration, @invalid_attrs)
    assert declaration == Declarations.get_declaration!(declaration.id)
  end

  test "delete_declaration/1 deletes the declaration" do
    declaration = fixture(:declaration)
    assert {:ok, %Declaration{}} = Declarations.delete_declaration(declaration)
    assert_raise Ecto.NoResultsError, fn -> Declarations.get_declaration!(declaration.id) end
  end

  test "change_declaration/1 returns a declaration changeset" do
    declaration = fixture(:declaration)
    assert %Ecto.Changeset{} = Declarations.change_declaration(declaration)
  end
end
