# The default exception handling for I18n does not allow to catch missing
# translations during automated tests. This custom exception handler will
# actually raise exceptions instead of silently swallowing them.
module I18n
  class ActuallyRaiseExceptionHandler < ExceptionHandler
    def call(exception, locale, key, options)
      if exception.is_a?(MissingTranslation)
        raise exception.to_exception
      else
        super
      end
    end
  end
end

I18n.exception_handler = I18n::ActuallyRaiseExceptionHandler.new
