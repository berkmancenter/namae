module Namae
  
  # A Name represents a single personal name, exposing its constituent
  # parts (e.g., family name, given name etc.). Name instances are typically
  # created and returned from {Namae.parse Namae.parse}.
  #
  #     name = Namae.parse('Yukihiro "Matz" Matsumoto')[0]
  #     
  #     name.family #=> Matsumoto
  #     name.nick #=> Matz
  #     name.given #=> Yukihiro
  #
  class Name < Struct.new :family, :given, :suffix, :particle,
    :dropping_particle, :nick, :appellation, :title

    # rbx compatibility
    @parts = members.map(&:to_sym).freeze

    @defaults = {
      :initials => {
        :expand => false,
        :dots => true,
        :spaces => false
      }
    }
    
    class << self
      attr_reader :parts, :defaults

      # @param name [String] the name to be parsed
      # @raise [ArgumentError] if the name cannot be parsed or if the input
      #   contains more than a single name
      # @return [Name] the parsed name
      def parse!(name)
        Parser.instance.parse!(name)[0] || new
      end
      
      # @param name [String] the name to be parsed
      # @return [Name] the parsed name
      def parse(name)
        parse!(name)
      rescue
        new
      end
    end

    
    # @param attributes [Hash] the individual parts of the name
    # @example
    #   Name.new(:family => 'Matsumoto')
    def initialize(attributes = {})
      super(*attributes.values_at(*Name.parts))
    end
  
    # @return [String] the name in sort order
    def sort_order(delimiter = ', ')
      [family_part, given_part].reject(&:empty?).join(delimiter)
    end

    # @return [String] the name in display order
    def display_order
      [given_part, family_part].reject(&:empty?).join(' ')
    end

    # @return [Boolean] whether or not all the name components are nil.
    def empty?
      values.compact.empty?
    end

    # Merges the name with the passed-in name or hash.
    #
    # @param other [#each_pair] the other name or hash
    # @return [self]
    def merge(other)
      raise ArgumentError, "failed to merge #{other.class} into Name" unless
        other.respond_to?(:each_pair)
        
      other.each_pair do |part, value|
        writer = "#{part}="
        send(writer, value) if !value.nil? && respond_to?(writer)
      end
      
      self
    end
    
    # @param options [Hash] the options to create the initials
    #
    # @option options [true,false] :expand (false) whether or not to expand the family name
    # @option options [true,false] :dots (true) whether or not to print dots between the initials
    # @option options [true,false] :spaces (false) whether or not to print spaces between the initals
    #
    # @return [String] the name's initials.
    def initials(options = {})
      options = Name.defaults[:initials].merge(options)
      
      if options[:expand]
        [initials_of(given_part, options), family].compact.join(' ')
      else
        initials_of([given_part, family_part].join(' '), options)
      end
    end

    # @overload values_at(selector, ... )
    #   Returns an array containing the elements in self corresponding to
    #   the given selector(s). The selectors may be either integer indices,
    #   ranges (functionality inherited from Struct) or symbols
    #   idenifying valid keys.
    #
    # @example
    #   name.values_at(:family, :nick) #=> ['Matsumoto', 'Matz']
    #
    # @see Struct#values_at
    # @return [Array] the list of values
    def values_at(*arguments)
      super(*arguments.flatten.map { |k| k.is_a?(Symbol) ? Name.parts.index(k) : k })
    end
    
    
    # @return [String] a string representation of the name
    def inspect
      "#<Name #{each_pair.map { |k,v| [k,v.inspect].join('=') if v }.compact.join(' ')}>"
    end
    
    alias to_s display_order

    private
    
    def family_part
      [particle, family].compact.join(' ')
    end
    
    def given_part
      [given, dropping_particle].compact.join(' ')
    end
    
    # @param name [String] a name or part of a name
    # @return [String] the initials of the passed-in name
    def initials_of(name, options = {})
      i = name.gsub(/([[:upper:]])[[:lower:]]+/, options[:dots] ? '\1.' : '\1')
      i.gsub!(/\s+/, '') unless options[:spaces]
      i
    end

  end
end