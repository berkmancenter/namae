module Namae

  # A list of parsed names.
  class Names < Array
    attr_writer :others

    # @return [Boolean] whether the list ended in 'et al.' or 'and others'.
    def others?
      !!@others
    end
  end
end
