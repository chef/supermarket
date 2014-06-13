# Instead of wrapping form fields with errors in a div (which messes up the grid
# layout), just add an error class to them.
#
# See http://stackoverflow.com/a/8380400/161787

ActionView::Base.field_error_proc = proc do |html_tag, _instance|
  class_attr_index = html_tag.index 'class="'

  if class_attr_index
    html_tag.insert class_attr_index + 7, 'error '
  else
    html_tag.insert html_tag.index('>'), ' class="error"'
  end
end
