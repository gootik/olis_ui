defmodule OlisUI.Shared do
  @moduledoc false

  def button_classes(variant, size, full_width \\ false, icon_only \\ false) do
    [
      "button button--#{variant} button--#{size} olis-action",
      full_width && "button--full-width",
      icon_only && "button--icon-only"
    ]
  end

  def close_button_classes(compact \\ false) do
    ["close-button close-button--default olis-dismiss", compact && "olis-dismiss--compact"]
  end

  def range_percent(nil, _min, _max), do: nil
  def range_percent(value, min, max), do: (value - min) / (max - min) * 100

  def label_classes, do: "label olis-label"
  def search_field_classes, do: "search-field olis-field"
  def search_group_classes, do: "search-field__group olis-field-frame"
  def search_input_classes, do: "search-field__input olis-field-entry"
  def search_clear_classes, do: "search-field__clear-button me-2 size-5! shrink-0"

  def select_trigger_classes, do: "select__trigger olis-field-frame olis-choice-trigger"

  def autocomplete_trigger_classes,
    do: "autocomplete__trigger olis-field-frame olis-choice-trigger"

  def select_indicator_classes, do: "select__indicator olis-choice-chevron"

  def overlay95_motion_classes, do: overlay_motion_classes()
  def overlay_motion_classes, do: "olis-overlay-motion"

  def select_popover_classes,
    do: "select__popover olis-option-surface olis-overlay-motion scrollbar"

  def field_error_classes, do: "field-error olis-field-error"

  def input_classes(variant), do: ["input input--#{variant} olis-field-frame"]

  def checkbox_root_classes(variant),
    do: ["checkbox checkbox--#{variant} olis-native-checkbox olis-choice"]

  def checkbox_control_classes, do: "checkbox__control olis-choice-box"
  def checkbox_content_classes, do: "checkbox__content olis-choice-body"
  def checkbox_indicator_classes, do: "checkbox__indicator olis-choice-mark"

  def dropdown_popover_classes do
    "dropdown__popover olis-dropdown-popover olis-option-surface olis-overlay-motion scrollbar"
  end

  def menu_item_classes, do: "menu-item olis-option"
  def menu_indicator_classes, do: "menu-item__indicator olis-option-mark"
  def list_box_item_classes, do: "list-box-item olis-option"
  def list_box_indicator_classes, do: "list-box-item__indicator olis-option-mark"
end
