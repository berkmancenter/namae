require 'singleton'

## Warning, this still isn't thread safe
module Namae
  class ParserOptions
    include Singleton

    attr_reader :options

    def initialize
      @options = {
      :debug => false,
      :prefer_comma_as_separator => false,
      :comma => ',',
      :stops => ',;',
      :separator => /\s*(\band\b|\&|;)\s*/i,
      :title => /\s*\b(sir|lord|count(ess)?|(gen|adm|col|maj|capt|cmdr|lt|sgt|cpl|pvt|pastor|pr|reverend|rev|elder|deacon|deaconess|father|fr|vicar|prof|dr|md|ph\.?d)\.?)(\s+|$)/i,
      :suffix => /\s*\b(JR|Jr|jr|SR|Sr|sr|[IVX]{2,})(\.|\b)/,
      :appellation => /\s*\b((mrs?|ms|fr|hr)\.?|miss|herr|frau)(\s+|$)/i
    }
  end

    def debug?
      options[:debug] || ENV['DEBUG']
    end

    def separator
      options[:separator]
    end

    def comma
      options[:comma]
    end

    def stops
      options[:stops]
    end

    def title
      options[:title]
    end

    def suffix
      options[:suffix]
    end

    def appellation
      options[:appellation]
    end

    def prefer_comma_as_separator?
      options[:prefer_comma_as_separator]
    end
  end
end
