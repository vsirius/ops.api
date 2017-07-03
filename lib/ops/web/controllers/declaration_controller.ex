defmodule OPS.Web.DeclarationController do
  @moduledoc false

  use OPS.Web, :controller

  alias OPS.DeclarationAPI
  alias OPS.Declaration

  action_fallback OPS.Web.FallbackController

  def index(conn, params) do
    with {:ok, declarations} <- DeclarationAPI.list_declarations(params) do
      render(conn, "index.json", declarations: declarations)
    end
  end

  def create(conn, %{"declaration" => declaration_params}) do
    result = DeclarationAPI.create_declaration(declaration_params)

    with {:ok, %Declaration{} = declaration} <- result do
      conn
      |> put_status(:created)
      |> put_resp_header("location", declaration_path(conn, :show, declaration))
      |> render("show.json", declaration: declaration)
    end
  end

  def show(conn, %{"id" => id}) do
    declaration = DeclarationAPI.get_declaration!(id)
    render(conn, "show.json", declaration: declaration)
  end

  def update(conn, %{"id" => id, "declaration" => declaration_params}) do
    declaration = DeclarationAPI.get_declaration!(id)
    result = DeclarationAPI.update_declaration(declaration, declaration_params)
    with {:ok, %Declaration{} = declaration} <- result do
      render(conn, "show.json", declaration: declaration)
    end
  end

  def delete(conn, %{"id" => id}) do
    declaration = DeclarationAPI.get_declaration!(id)
    with {:ok, %Declaration{}} <- DeclarationAPI.delete_declaration(declaration) do
      send_resp(conn, :no_content, "")
    end
  end

  def create_with_termination_logic(conn, declaration_params) do
    case DeclarationAPI.create_declaration_with_termination_logic(declaration_params) do
      {:ok, %{new_declaration: declaration}} ->
        render(conn, "show.json", declaration: declaration)
      {:error, _transaction_step, changeset, _} -> {:error, changeset}
    end
  end
end
