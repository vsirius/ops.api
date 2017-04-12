defmodule OPS.Web.PageController do
  @moduledoc """
  Sample controller for generated application.
  """
  use OPS.Web, :controller

  action_fallback OPS.Web.FallbackController

  def index(conn, _params) do
    render conn, "page.json"
  end
end
