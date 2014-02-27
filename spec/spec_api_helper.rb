require 'spec_helper'

def signature(resource)
  resource.except('created_at', 'updated_at')
end

def error_404
  {
     'error_messages' => ['Resource does not exist'],
     'error_code' => 'NOT_FOUND'
  }
end
