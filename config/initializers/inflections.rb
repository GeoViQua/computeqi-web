# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format
# (all these examples are active by default):
ActiveSupport::Inflector.inflections do |inflect|
  inflect.singular("analysis", "analysis")
  inflect.plural("analysis", "analyses")
  inflect.irregular("analysis_value", "analysis_values")
  inflect.irregular("analysis_input_value", "analysis_input_values")
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
end
