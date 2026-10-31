defmodule OlisUI.Base do
  @moduledoc "Form wrappers and field messages."
  use Phoenix.Component, global_prefixes: ~w(x-)
  import OlisUI.Shared

  @doc """
  A Phoenix form with native submission, validation and LiveView support.

  Uses the same options and slot form value as `Phoenix.Component.form/1`. Named
  `ui_form` to avoid an import conflict with Phoenix's built-in `form` component.
  """
  attr(:for, :any, required: true)
  attr(:action, :string)
  attr(:as, :atom)
  attr(:csrf_token, :any)
  attr(:errors, :list)
  attr(:method, :string)
  attr(:multipart, :boolean, default: false)
  attr(:rest, :global, include: ~w(autocomplete name rel enctype novalidate target))
  slot(:inner_block, required: true)

  def ui_form(assigns), do: Phoenix.Component.form(assigns)

  @doc "Supplementary text for a form field or other component."
  attr(:class, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def description(assigns) do
    ~H"""
    <span
      class={["description text-xs text-wrap wrap-break-word text-muted", @class]}
      data-slot="description"
      {@rest}
    >
      {render_slot(@inner_block)}
    </span>
    """
  end

  @doc "A field validation message. Control visibility explicitly with `visible`."
  attr(:visible, :boolean, default: true)
  attr(:class, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def field_error(assigns) do
    ~H"""
    <span
      class={[field_error_classes(), @class]}
      data-slot="field-error"
      data-visible={if @visible, do: "true"}
      hidden={!@visible}
      {@rest}
    >{render_slot(@inner_block)}</span>
    """
  end

  @doc "An error message for a non-form component such as a tag group."
  attr(:class, :any, default: nil)
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def error_message(assigns) do
    ~H"""
    <span
      class={[
        "error-message olis-field-error olis-field-error--visible",
        @class
      ]}
      data-slot="error-message"
      {@rest}
    >
      {render_slot(@inner_block)}
    </span>
    """
  end
end
