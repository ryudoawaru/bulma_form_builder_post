class BulmaFormBuilder < ::ActionView::Helpers::FormBuilder
  def container_tag(base_dom_class, content_or_options = nil, options = {}, &block)
    options = content_or_options if content_or_options.is_a?(Hash)
    content_or_options = @template.capture(&block) if block_given?
    options[:class] = [options.dig(:class), base_dom_class].compact.join(" ")
    @template.content_tag(:div, content_or_options, options)
  end

  def field_container(content_or_options = nil, options = {}, &block)
    container_tag "field", content_or_options, options, &block
  end

  def around_input(method, options = {}, &block)
    options[:class] = [options.delete(:class), "input"].compact.join(" ")
    help_text = options.delete(:help) || fetch_i18n_help_text(method)
    help_tag = help_text ? @template.content_tag(:p, help_text, class: "help") : ""
    input_html = @template.capture(&block)
    label_tag(method, options) + container_tag("control", input_html + help_tag)
  end

  def label_tag(method, options = {})
    options[:hide_label] ? @template.raw("") : label(method, options.delete(:label), class: "label")
  end

  def self.bulma_field(field_method_name)
    define_method "bulma_#{field_method_name}" do |method, options = {}|
      field_container do
        around_input(method, options) do
          send(field_method_name, method, options)
        end
      end
    end
  end

  %i[color_field date_field email_field password_field text_field datetime_field datetime_local_field number_field phone_field range_field].each do |field_name|
    bulma_field field_name
  end

  def bulma_select(method, choices = nil, options = {}, html_options = {}, &block)
    field_container do
      around_input(method, options) do
        @template.content_tag(:div, select(method, choices, options, html_options, &block), class: "select")
      end
    end
  end

  def bulma_collection_radio_buttons(method, collection, value_method, text_method, options = {}, html_options = {})
    field_container do
      label_tag(method, options) + container_tag("control") do
        collection_radio_buttons(method, collection, value_method, text_method, options, html_options) do |b|
          b.radio_button + b.label(class: "radio")
        end
      end
    end
  end

  def bulma_collection_check_boxes(method, collection, value_method, text_method, options = {}, html_options = {})
    field_container do
      label_tag(method, options) + container_tag("control") do
        collection_check_boxes(method, collection, value_method, text_method, options, html_options) do |b|
          b.check_box + b.label(class: "radio")
        end
      end
    end
  end

  private

  def fetch_i18n_help_text(method)
    t_scope = ["helpers", "help", @object_name, method].join(".")
    I18n.t(t_scope, default: nil)
  end
end
