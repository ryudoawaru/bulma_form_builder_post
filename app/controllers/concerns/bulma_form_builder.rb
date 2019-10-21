class BulmaFormBuilder < ::ActionView::Helpers::FormBuilder
  def container_tag(base_com_class, content_or_options =nil, options = {}, &block)
    options = content_or_options if content_or_options.is_a?(Hash)
    content_or_options = @template.capture(&block) if block_given?
    options[:class] = [options.dig(:class).to_s, base_com_class].join(" ")
    @template.content_tag(:div, content_or_options, options)
  end

  %w[field control].each do |klass|
    define_method "#{klass}_container" do |content_or_options = nil, options = {}, &block|
      container_tag(klass, content_or_options = nil, options = {}, &block)
    end
  end

  def fetch_i18n_help_text(method)
    t_scope = ["helpers", "help", @object_name, method].join(".")
    I18n.t(t_scope, default: nil)
  end

  def self.bulma_field(field_method_name)
    define_method "bulma_#{field_method_name}" do |method, options = {}|
    options[:class] = [options.delete(:class), "input"].compact.join(" ")
      help_text = options.delete(:help) || fetch_i18n_help_text(method)
      help_tag = help_text ? @template.content_tag(:p, help_text, class: "help") : ""
      field_container do
        label(method, options.delete(:label), class: "label") + control_container do
          send(field_method_name, method, options) + help_tag
        end
      end
    end
  end

  %i[color_field date_field email_field password_field text_field datetime_field datetime_local_field number_field phone_field range_field].each do |field_name|
    bulma_field field_name
  end

end
