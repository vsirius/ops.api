defmodule OPS.Search do
  @moduledoc """
  Search implementation
  """

  defmacro __using__(_) do
    quote  do
      import Ecto.{Query, Changeset}, warn: false
      import OPS.Search

      alias OPS.Repo

      def search(%Ecto.Changeset{valid?: true, changes: changes}, search_params, entity, default_limit) do
        limit =
          search_params
          |> Map.get("limit", default_limit)
          |> to_integer()

        cursors = %Ecto.Paging.Cursors{
          starting_after: Map.get(search_params, "starting_after"),
          ending_before: Map.get(search_params, "ending_before")
        }

        entity
        |> get_search_query(changes)
        |> Repo.page(%Ecto.Paging{limit: limit, cursors: cursors})
      end

      def search(%Ecto.Changeset{valid?: false} = changeset, _search_params, _entity, _default_limit) do
        {:error, changeset}
      end

      def get_search_query(entity, changes) when map_size(changes) > 0 do
        params = Map.to_list(changes)

        from e in entity,
          where: ^params,
          order_by: [desc: :inserted_at]
      end
      def get_search_query(entity, _changes), do: from e in entity, order_by: [desc: :inserted_at]

      defoverridable [get_search_query: 2]
    end
  end

  def to_integer(value) when is_binary(value), do: String.to_integer(value)
  def to_integer(value), do: value
end
