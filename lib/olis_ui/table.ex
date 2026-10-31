defmodule OlisUI.Table do
  @moduledoc "Data tables with selection and sorting."
  use Phoenix.Component, global_prefixes: ~w(x-)
  import OlisUI.Shared

  @doc """
  A semantic, responsive OlisUI table. Column slots receive each row.

  Pass a LiveView stream as `rows` and a unique `id` for incremental updates.
  For server-side sorting, give columns `sort_key` and set `sort_event`; the
  event receives `%{"sort" => key}`. The caller owns the order and sort state.
  Use the `:empty` slot for custom empty content and `:footer` for pagination.
  Set `on_load_more` and `has_more` to request the next page when the end of
  the table reaches the viewport. The application owns loading and pagination.
  """
  attr(:id, :string, default: nil)
  attr(:rows, :any, required: true)
  attr(:label, :string, required: true)
  attr(:variant, :string, default: "primary", values: ~w(primary secondary))
  attr(:row_id, :any, default: nil)
  attr(:sort_event, :string, default: nil)
  attr(:sort_by, :string, default: nil)
  attr(:sort_direction, :string, default: "ascending", values: ~w(ascending descending))
  attr(:empty_message, :string, default: "No results found.")
  attr(:selection_mode, :string, default: "none", values: ~w(none single multiple))
  attr(:selected_keys, :list, default: [])
  attr(:disabled_keys, :list, default: [])
  attr(:row_label, :any, default: nil)
  attr(:on_selection_change, :string, default: nil)
  attr(:on_column_resize, :string, default: nil)
  attr(:on_load_more, :any, default: nil)
  attr(:has_more, :boolean, default: false)
  attr(:loading, :boolean, default: false)
  attr(:target, :any, default: nil)
  attr(:class, :any, default: nil)

  slot :col, required: true do
    attr(:label, :string, required: true)
    attr(:sort_key, :string)
    attr(:row_header, :boolean)
    attr(:key, :string)
    attr(:resizable, :boolean)
    attr(:width, :integer)
    attr(:min_width, :integer)
    attr(:max_width, :integer)
    attr(:class, :any)
  end

  slot(:empty)
  slot(:footer)
  slot(:load_more)

  def data_table(assigns) do
    stream? = match?(%Phoenix.LiveView.LiveStream{}, assigns.rows)

    selected = assigns.selected_keys

    columns =
      assigns.col
      |> Enum.with_index()
      |> Enum.map(fn {col, index} ->
        key = Map.get(col, :key) || Integer.to_string(index)
        min_width = Map.get(col, :min_width) || 48
        max_width = Map.get(col, :max_width) || 2000

        Map.merge(col, %{column_key: key, min_width: min_width, max_width: max_width})
      end)

    assigns =
      assign(assigns,
        columns: columns,
        resizable?: Enum.any?(columns, &Map.get(&1, :resizable, false)),
        stream?: stream?,
        empty?: !stream? and assigns.rows == [],
        selected_set: MapSet.new(selected),
        disabled_set: MapSet.new(assigns.disabled_keys),
        encoded_selected: Jason.encode!(selected)
      )

    ~H"""
    <div
      class={[
        "table-root table-root--#{@variant} olis-table",
        @variant == "primary" && "rounded-[12px] bg-surface-secondary px-1 pb-1",
        @class
      ]}
      data-olis-table="true"
      data-selection-mode={if @selection_mode != "none", do: @selection_mode}
      data-selected-keys={if @selection_mode != "none", do: @encoded_selected}
      x-data="olisTable"
      x-on:keydown="keyDown($event)"
      x-on:focusin="focusIn($event)"
      x-on:focusout="focusOut($event)"
      x-on:pointermove.window={if @resizable?, do: "resizeMove($event)"}
      x-on:pointerup.window={if @resizable?, do: "resizeEnd($event)"}
      x-on:pointercancel.window={if @resizable?, do: "resizeCancel($event)"}
      x-on:change={if @selection_mode != "none", do: "selectionChange($event)"}
      x-on:click={if @selection_mode != "none", do: "rowClick($event)"}
      x-on:phx:update.document="sync()"
    >
      <div
        id={if @on_load_more, do: "#{@id}-scroll"}
        phx-viewport-bottom={if @on_load_more && @has_more && !@loading, do: @on_load_more}
        phx-target={if @on_load_more, do: @target}
      >
        <div class={[
          "table__scroll-container scrollbar overflow-x-auto [scrollbar-gutter:auto]",
          @resizable? && "table__resizable-container relative overflow-auto"
        ]}>
          <table
            id={@id}
            class={[
              "table__content w-full border-separate border-spacing-0 text-sm",
              @variant == "primary" && "overflow-clip"
            ]}
            aria-label={@label}
            x-bind:role="'grid'"
            tabindex="0"
            x-bind:aria-multiselectable="$root.dataset.selectionMode === 'multiple' ? 'true' : null"
            phx-mounted={if @resizable?, do: Phoenix.LiveView.JS.ignore_attributes(["style"])}
          >
            <colgroup :if={@resizable?}>
              <col
                :if={@selection_mode != "none"}
                data-table-column-key="__selection__"
                data-width="48"
                style="width: 48px"
              />
              <col
                :for={col <- @columns}
                data-table-column-key={col.column_key}
                data-min-width={col.min_width}
                data-max-width={col.max_width}
                data-width={Map.get(col, :width)}
                style={if Map.get(col, :width), do: "width: #{col.width}px"}
                phx-mounted={Phoenix.LiveView.JS.ignore_attributes(["style"])}
              />
            </colgroup>
            <thead class={[
              "table__header",
              @variant == "primary" && "border-b border-separator/50 bg-surface-secondary",
              @variant == "secondary" && "border-b-0 bg-transparent"
            ]}>
              <tr>
                <th
                  :if={@selection_mode != "none"}
                  scope="col"
                  class={[table_column_classes(@variant), "w-12"]}
                >
                  <.table_selection_control
                    :if={@selection_mode == "multiple"}
                    label="Select all rows"
                    select_all
                  />
                  <span :if={@selection_mode == "single"} class="sr-only">Selection</span>
                </th>
                <th
                  :for={{col, index} <- Enum.with_index(@columns)}
                  scope="col"
                  class={[table_column_classes(@variant), Map.get(col, :class)]}
                  data-allows-sorting={if @sort_event && Map.get(col, :sort_key), do: "true"}
                  aria-sort={if @sort_by && @sort_by == Map.get(col, :sort_key), do: @sort_direction}
                >
                  <button
                    :if={@sort_event && Map.get(col, :sort_key)}
                    type="button"
                    class="table__sortable-column-header olis-table-sort"
                    phx-click={@sort_event}
                    phx-value-sort={col.sort_key}
                  >
                    {col.label}<OlisUI.Icon.icon
                      name="chevron-up"
                      class="table__sortable-column-indicator olis-sort-marker"
                      data-direction={if @sort_by == col.sort_key, do: @sort_direction}
                    />
                  </button>
                  <span :if={!@sort_event || !Map.get(col, :sort_key)}>{col.label}</span>
                  <div
                    :if={Map.get(col, :resizable, false)}
                    class={[
                      "table__column-resizer olis-resize-handle",
                      index == length(@columns) - 1 && "translate-x-0",
                      index != length(@columns) - 1 && "translate-x-1/2"
                    ]}
                    role="separator"
                    tabindex="0"
                    aria-label={"Resize #{col.label} column"}
                    aria-orientation="vertical"
                    aria-valuemin={col.min_width}
                    aria-valuemax={col.max_width}
                    aria-valuenow={Map.get(col, :width)}
                    data-table-resizer={col.column_key}
                    x-on:focus="syncWidths()"
                    x-on:pointerdown="resizeStart($event)"
                    x-on:keydown="resizeKey($event)"
                    x-on:click.stop
                  >
                  </div>
                </th>
              </tr>
            </thead>
            <tbody
              id={if @stream?, do: "#{@id}-body"}
              phx-update={if @stream?, do: "stream"}
              class="table__body"
            >
              <tr
                :for={item <- @rows}
                id={table_row_id(item, @stream?, @row_id)}
                class={table_row_classes()}
                data-olis-table-row="true"
                data-key={if @selection_mode != "none", do: table_row_id(item, @stream?, @row_id)}
                data-selected={
                  if @selection_mode != "none" and
                       MapSet.member?(@selected_set, table_row_id(item, @stream?, @row_id)),
                     do: "true"
                }
                aria-selected={
                  if @selection_mode != "none",
                    do:
                      to_string(MapSet.member?(@selected_set, table_row_id(item, @stream?, @row_id)))
                }
              >
                <td
                  :if={@selection_mode != "none"}
                  class={[table_cell_classes(@variant, false), "w-12"]}
                >
                  <.table_selection_control
                    label={table_selection_label(item, @stream?, @row_id, @row_label)}
                    selected={MapSet.member?(@selected_set, table_row_id(item, @stream?, @row_id))}
                    disabled={MapSet.member?(@disabled_set, table_row_id(item, @stream?, @row_id))}
                  />
                </td>
                <%= for col <- @col do %>
                  <th
                    :if={Map.get(col, :row_header, false)}
                    scope="row"
                    class={table_cell_classes(@variant, true)}
                  >
                    {render_slot(col, table_row_value(item, @stream?))}
                  </th>
                  <td
                    :if={!Map.get(col, :row_header, false)}
                    class={table_cell_classes(@variant, false)}
                  >
                    {render_slot(col, table_row_value(item, @stream?))}
                  </td>
                <% end %>
              </tr>
              <tr
                :if={@empty? || @stream?}
                id={if @stream?, do: "#{@id}-empty"}
                class={[table_row_classes(), @stream? && "hidden only:table-row"]}
              >
                <td
                  class={table_cell_classes(@variant, false)}
                  colspan={length(@col) + if(@selection_mode == "none", do: 0, else: 1)}
                >
                  <%= if @empty == [] do %>
                    {@empty_message}
                  <% else %>
                    {render_slot(@empty)}
                  <% end %>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <div
          :if={@on_load_more && @has_more}
          id={"#{@id}-load-more"}
          class="table__load-more-content flex items-center justify-center gap-2 py-2"
          data-slot="table-load-more-content"
          aria-live="polite"
        >
          <%= if @load_more == [] do %>
            <OlisUI.Display.spinner :if={@loading} size="sm" decorative />
            <span class="text-sm text-muted">{if @loading,
              do: "Loading more…",
              else: "Scroll for more"}</span>
          <% else %>
            {render_slot(@load_more)}
          <% end %>
        </div>
      </div>
      <div
        :if={@footer != []}
        class="table__footer flex items-center px-4 py-2.5"
        data-slot="table-footer"
      >
        {render_slot(@footer)}
      </div>
      <button
        :if={@on_column_resize}
        type="button"
        hidden
        data-olis-table-resize-event
        phx-click={@on_column_resize}
        phx-target={@target}
      ></button>
      <button
        :if={@on_selection_change}
        type="button"
        hidden
        data-olis-table-selection-event
        phx-click={@on_selection_change}
        phx-target={@target}
      ></button>
    </div>
    """
  end

  defp table_column_classes(variant),
    do: "table__column olis-table-heading olis-table-heading--#{variant}"

  defp table_row_classes, do: "table__row olis-table-row"

  defp table_cell_classes(variant, row_header?) do
    [
      "table__cell olis-table-cell olis-table-cell--#{variant}",
      row_header? && "olis-table-cell--row-heading"
    ]
  end

  attr(:label, :string, required: true)
  attr(:select_all, :boolean, default: false)
  attr(:selected, :boolean, default: false)
  attr(:disabled, :boolean, default: false)

  defp table_selection_control(assigns) do
    ~H"""
    <label
      class={[checkbox_root_classes("primary"), "group"]}
      data-slot="checkbox"
      data-disabled={if @disabled, do: "true"}
    >
      <span class={checkbox_content_classes()} data-slot="checkbox-content">
        <input
          type="checkbox"
          class="olis-visually-hidden-input absolute [inset-block-start:0] start-0 z-[2] m-0 size-4 cursor-inherit opacity-0"
          aria-label={@label}
          checked={@selected}
          disabled={@disabled}
          data-olis-table-select-all={if @select_all, do: "true"}
          data-olis-table-select-row={if !@select_all, do: "true"}
        />
        <span class={checkbox_control_classes()} aria-hidden="true"><span class={
          checkbox_indicator_classes()
        }><OlisUI.Icon.icon
          name="check"
          class="size-full group-data-[indeterminate=true]:hidden"
          data-slot="checkbox-default-indicator--checkmark"
        /><OlisUI.Icon.icon
          name="minus"
          class="size-full group-[:not([data-indeterminate=true])]:hidden"
          data-slot="checkbox-default-indicator--indeterminate"
        /></span></span>
      </span>
    </label>
    """
  end

  defp table_selection_label(item, stream?, row_id, row_label) do
    value = table_row_value(item, stream?)
    "Select #{if row_label, do: row_label.(value), else: table_row_id(item, stream?, row_id)}"
  end

  defp table_row_value({_id, row}, true), do: row
  defp table_row_value(row, false), do: row
  defp table_row_id({id, _row}, true, _row_id), do: id
  defp table_row_id(row, false, row_id) when is_function(row_id, 1), do: row_id.(row)
  defp table_row_id(_row, false, nil), do: nil
end
