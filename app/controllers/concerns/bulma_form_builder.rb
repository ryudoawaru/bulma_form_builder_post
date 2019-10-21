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
end
