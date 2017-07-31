defmodule OPS.DeclarationTerminatorTest do
  @moduledoc false

  use OPS.Web.ConnCase

  alias OPS.DeclarationTerminator
  alias OPS.Declarations.Declaration

  test "start init genserver" do
    insert(:declaration)
    [%Declaration{status: "active"}] = Repo.all(Declaration)
    {:ok, pid} = DeclarationTerminator.start_link()
    Process.sleep(100)
    [%Declaration{status: "closed"}] = Repo.all(Declaration)
    Process.exit(pid, :kill)
  end
end
