defmodule OPS.Web.DeclarationReportController do
  @moduledoc false
  use OPS.Web, :controller
  alias OPS.Declaration.Report

  action_fallback OPS.Web.FallbackController

  def declarations(conn, params) do
    with {:ok, declarations} <- Report.report(params) do
      render(conn, "declarations_report.json", declarations: declarations)
    end
  end
end
